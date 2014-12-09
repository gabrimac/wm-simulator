require 'sinatra'
require 'sinatra/base'
require 'savon'
require 'pry-byebug'
require 'sinatra/content_for'
require "sinatra/reloader" if development?

class App < Sinatra::Application

  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

  get '/' do
    welcome_active
    @title = 'WebMethods Simulator'
    haml :index
  end

  def welcome_active
    @welcome_active = "active"
    @logs_active = ""
    @bods_active = ""
  end
end

require_relative 'models/init'
require_relative 'routes/init'
