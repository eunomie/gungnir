require 'rugged'

module Git
  class Repo
    attr_accessor :repo
    def initialize(path)
      @path = path
      @repo = nil
      create_if_not_exists
      update_index
    end

    def write(content, path, message)
      commit(tree(blob(content), path), message)
    end

    def all
      result = []
      oids = get_all
      oids.each do |oid|
        item = YAML.load @repo.read(oid).data
        result.push item
      end
      result.sort { |a, b| b["time"] <=> a["time"] }
    end

    def mark_as_done id
      obj = get(id)
      return if obj == nil
      item = YAML.load @repo.read(obj).data
      item["done"] = true
      write(item.to_yaml, id, "mark as done")
    end

    def delete (id, message)
      commit(remove(id), message)
    end

    private

    def blob(content)
      @repo.write(content, :blob)
    end

    def tree(oid, path)
      @index.add(:path => path, :oid => oid, :mode => 0100644)
      @index.write_tree(@repo)
    end

    def remove(path)
      @index.remove(path)
      @index.write_tree(@repo)
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

    def get path
      return nil if @repo.empty?
      tree = @repo.lookup(@repo.head.target).tree
      obj = nil
      tree.walk_blobs(:postorder) do |root, entry|
        if "#{root}#{entry[:name]}" == path
          obj = entry[:oid]
          break
        end
      end
      obj
    end

    def get_all
      result = []
      return result if @repo.empty?
      tree = @repo.lookup(@repo.head.target).tree
      tree.walk_blobs(:postorder) do |root, entry|
        result.push(entry[:oid])
      end
      result
    end

    def update_index
      @index = Rugged::Index.new
      return if @repo.empty?
      tree = @repo.lookup(@repo.head.target).tree
      tree.walk_blobs(:postorder) do |root, entry|
        @index.add(:path => "#{root}#{entry[:name]}", :oid => entry[:oid], :mode => 0100644)
      end
    end

    def create_if_not_exists
      if File.exists?(@path)
        @repo = Rugged::Repository.new(@path)
      else
        @repo = Rugged::Repository.init_at(@path)
      end
    end
  end
end
