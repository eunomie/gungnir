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

  get '/done/:id' do |id|
    gungnir.mark_as_done id
    redirect '/'
  end

  get '/delete/:id' do |id|
    gungnir.delete id
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

  get '/:hash?' do |hash|
    @items = gungnir.all hash
    @current = hash || 'master'
    @prev = repo.prev hash
    @next = repo.next hash
    redirect '/new' if @items.empty?
    haml :index
  end
end
