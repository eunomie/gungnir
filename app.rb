require "bundler"
Bundler.require
require 'yaml'
include Sprockets::Helpers

REPO_PATH = "git-backend"

def write(repo, content, path, message)
  commit(repo, tree(repo, blob(repo, content), path), message)
end

def blob(repo, content)
  repo.write(content, :blob)
end

def tree(repo, oid, path)
  index = Rugged::Index.new
  index.add(:path => path, :oid => oid, :mode => 0100644)
  index.write_tree(repo)
end

def commit(repo, tree, message)
  options = {}
  options[:tree] = tree
  options[:author] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
  options[:committer] = { :email => "contact@sogilis.com", :name => 'sogilis', :time => Time.now }
  options[:message] ||= message
  options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
  options[:update_ref] = 'HEAD'

  Rugged::Commit.create(repo, options)
end

class Item
  attr_accessor :id
  attr_accessor :content

  @@items = []

  def initialize(content, time)
    @id = SecureRandom.uuid
    @content = content
    @done = false
    @time = time
  end

  def done?
    @done
  end

  def self.all
    if @@items.empty?
      @@items = [Item.new("faire une app sinatra", Time.now), Item.new("utiliser git", Time.now)]
    end
    @@items
  end

  def self.create(content, time, repo)
    item = Item.new(content, time)
    write(repo, item.to_yaml, "items/#{item.id}", "new item")
  end

  def to_yaml
    {"id" => @id, "content" => @content, "time" => @time, "done" => @done}.to_yaml
  end
end

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new(root)

  if File.exists?(REPO_PATH)
    repo = Rugged::Repository.new(REPO_PATH)
  else
    repo = Rugged::Repository.init_at(REPO_PATH, :bare)
  end

  get '/' do
    @items = Item.all()
    redirect '/new' if @items.empty?
    haml :index
  end

  get '/new' do
    @title = "Add todo list"
    haml :new
  end

  post '/new' do
    Item.create(params[:content], Time.now, repo)
    redirect '/'
  end
end
