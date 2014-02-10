require "bundler"
Bundler.require
require 'yaml'
include Sprockets::Helpers

require_relative "lib/git"

REPO_PATH = "git-backend"

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new(root)

  repo = Git::Repo.new(REPO_PATH)

  get '/' do
    @items = repo.all
    redirect '/new' if @items.empty?
    haml :index
  end

  get '/new' do
    @title = "Add todo list"
    haml :new
  end

  post '/new' do
    item = {"id" => SecureRandom.uuid, "content" => params[:content], "done" => false, "time" => Time.now}
    repo.write(item.to_yaml, "items/#{item["id"]}", "add a todo")
    redirect '/'
  end
end
