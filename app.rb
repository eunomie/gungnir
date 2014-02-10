require "bundler"
Bundler.require
include Sprockets::Helpers

class Item
  attr_accessor :id
  attr_accessor :content

  @@id = 0

  @@items = []

  def initialize(content, time)
    @id = @@id
    @@id = @@id + 1
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
