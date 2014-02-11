require 'rugged'

module Git
  class Repo
    attr_accessor :repo
    def initialize(path)
      @path = path
      @repo = nil
      create_if_not_exists
    end

    def write(content, path, message)
      commit(tree(blob(content), path), message)
    end

    def delete (id, message)
      commit(remove(id), message)
    end

    def get path
      obj = oid path
      return nil if obj.nil?
      @repo.read(obj).data
    end

    def get_all rev = nil
      index = get_index rev
      result = []
      index.each do |item|
        result.push @repo.read(item[:oid]).data
      end
      result
    end

    def prev rev = nil
      return nil if @repo.empty?
      hash = rev || @repo.head.target
      tree = @repo.lookup hash
      parent = tree.parents.first
      parent.nil? ? nil : parent.oid
    end

    def next rev = nil
      return nil if rev == nil || rev == @repo.head.target
      walker = Rugged::Walker.new @repo
      walker.push @repo.head.target
      version = nil
      walker.each do |c|
        break if c.oid == rev
        version = c.oid
      end
      if version == @repo.head.target
        version = ''
      end
      version
    end

    private

    def blob(content)
      @repo.write(content, :blob)
    end

    def tree(oid, path)
      index = get_index
      index.add(:path => path, :oid => oid, :mode => 0100644)
      index.write_tree(@repo)
    end

    def remove(path)
      index = get_index
      index.remove(path)
      index.write_tree(@repo)
    end

    def commit(tree, message)
      options = {}
      options[:tree] = tree
      options[:author] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
      options[:committer] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
      options[:message] ||= message
      options[:parents] = @repo.empty? ? [] : [ @repo.head.target ].compact
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(@repo, options)
    end

    def oid path
      return nil if @repo.empty?
      tree = @repo.lookup(@repo.head.target).tree
      paths = path.split('/')
      get_oid tree, paths
    end

    def get_oid tree, paths
      key = paths.shift
      return nil if tree[key].nil?
      oid = tree[key][:oid]
      return oid if paths.empty?
      return nil if tree[key][:type] != :tree
      get_oid @repo.lookup(oid), paths
    end

    def get_index rev = nil
      index = Rugged::Index.new
      unless @repo.empty?
        hash = rev || @repo.head.target
        tree = @repo.lookup(hash).tree
        index.read_tree tree
      end
      index
    end

    def create_if_not_exists
      if File.exists?(@path)
        @repo = Rugged::Repository.new(@path)
      else
        @repo = Rugged::Repository.init_at(@path, :bare)
      end
    end
  end
end
