require 'sinatra'
require 'sinatra/base'
require 'savon'
require 'pry-byebug'
require 'sinatra/soap'
require 'sinatra/content_for'
require "sinatra/reloader" if development?

class App < Sinatra::Application

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

  get '/' do

    @title = 'WebMethods Simulator'
    haml :index
  end

  get '/files' do
    @files = Store.all

    haml :'files/index'
  end
end

require_relative 'models/init'
require_relative 'routes/init'
