require "bundler"
Bundler.require
include Sprockets::Helpers

REPO_PATH = "git-backend"

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

  def self.create(content, time)
    @@items.push(Item.new(content, time))
    @@items
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
    Item.create(params[:content], Time.now)
    redirect '/'
  end
end
