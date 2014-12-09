class App < Sinatra::Application

  post "/logs/create" do
    name = params[:log][:name] if params[:log][:name]
    content = params[:log][:body] if params[:log][:body]

    store = Store.new(name, content, "logs")

    redirect "/logs/index" if store.save
    haml :'logs/index'
  end


  get "/logs/new" do
    haml :'logs/new'
  end

  get "/logs/index" do
    @logs = Store.all("logs")

    haml :'logs/index'
  end

  get "/logs/operations/:filename" do
    @filename = params[:filename]
    log = Store.find(@filename, "logs")
    @responses = Response.find(@filename)
    @operations = Log.new(log).convert_to_operations

    haml :'logs/operations'
  end

  get "/logs/operations/:filename/send/:index" do
    filename = params[:filename]
    log = Store.find(filename, "logs")
    @operations = Log.new(log).convert_to_operations
    operation = @operations[params[:index].to_i]

    operation.execute(filename)
    redirect :"logs/operations/#{filename}"
  end
end
