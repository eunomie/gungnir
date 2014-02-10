require 'git'
require 'tmpdir'


describe Git::Repo, "#new" do
  context 'when no repository exists' do
    it "should create a bare one" do
      Dir.mktmpdir do |dir|
        git_path = File.join(dir, "test.git")

        git = Git::Repo.new(git_path).repo
        expect(git).to be_an_instance_of(Rugged::Repository)
        expect(git.bare?).to be(true)
        expect(git.empty?).to be(true)
      end
    end
  end

  context 'when a repository exists' do
    it "should use it" do
      Dir.mktmpdir do |dir|
        git_path = File.join(dir, "test.git")
        Rugged::Repository.init_at(git_path, :bare)
        expect(Git::Repo.new(git_path).repo).to be_an_instance_of(Rugged::Repository)
      end
    end
  end
end

describe Git::Repo, "#write" do
  before do
    @tmpdir = Dir.mktmpdir
    @git = Git::Repo.new(File.join(@tmpdir, "repo.git"))
  end

  it "should create commit" do
    @git.write("content", "path/file", "message")

    ##
  end

  after do
    `rm -Rf #{@tmpdir}`
  end
end
