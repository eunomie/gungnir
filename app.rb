require "bundler"
Bundler.require
require 'yaml'
include Sprockets::Helpers

require_relative "lib/git"
require_relative "lib/gungnir"

REPO_PATH = "git-backend"

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new(root)

  repo = Git::Repo.new(REPO_PATH)
  gungnir = Gungnir.new(repo)

  get '/' do
    @items = gungnir.all
    redirect '/new' if @items.empty?
    haml :index
  end

  get '/done/:id' do
    gungnir.mark_as_done params[:id]
    redirect '/'
  end

  get '/delete/:id' do
    gungnir.delete params[:id]
    redirect '/'
  end

  get '/new' do
    @title = "Add todo list"
    haml :new
  end

  post '/new' do
    item = {"id" => SecureRandom.uuid, "content" => params[:content], "done" => false, "time" => Time.now}
    gungnir.create(item)
    redirect '/'
  end
end
