require 'sinatra'
require 'sinatra/base'
require 'data_mapper'
require 'savon'
require 'pry-byebug'

class App < Sinatra::Base
  before do
    headers "Content-Type" => "text/html; charset=utf-8"
  end

  get '/' do
    @title = 'WebMethods Simulator'
    @files = Dir.entries("./public/xml")
    haml :index
  end

  get '/pex' do
    client = Savon.client(wsdl: 'http://localhost:3000/api/bods/action')

    @response = client.call(:create_bod_meta, message: {
      bod_id: '01234',
      gcc: 'ZZA',
      lcc: 'US001',
      payroll_exchange_id: '199511190',
      parent_bod_id: '43210',
      event: 'hiring',
      source_bod_id: '4230',
      system: '1001',
      batch_position: '/'
      })

    haml :show
  end
end
