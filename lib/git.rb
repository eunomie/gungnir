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

    private

    def blob(content)
      @repo.write(content, :blob)
    end

    def tree(oid, path)
      index = Rugged::Index.new
      index.add(:path => path, :oid => oid, :mode => 0100644)
      index.write_tree(@repo)
    end

    def commit(tree, message)
      options = {}
      options[:tree] = tree
      options[:author] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
      options[:committer] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
      options[:message] ||= message
      options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
      options[:update_ref] = 'HEAD'

      Rugged::Commit.create(@repo, options)
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
