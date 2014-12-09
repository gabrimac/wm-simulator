class App < Sinatra::Application

  post "/logs/create" do
    active_log
    name = params[:log][:name] if params[:log][:name]
    content = params[:log][:body] if params[:log][:body]

    store = Store.new(name, content, "logs")

    redirect "/logs/index" if store.save
    haml :'logs/index'
  end


  get "/logs/new" do
    active_log
    haml :'logs/new'
  end

  get "/logs/index" do
    active_log
    @logs = Store.all("logs")

    haml :'logs/index'
  end

  get "/logs/operations/:filename" do
    active_log
    @filename = params[:filename]
    log = Store.find(@filename, "logs")
    @responses = Response.find(@filename)
    @operations = Log.new(log).convert_to_operations

    haml :'logs/operations'
  end

  get "/logs/operations/:filename/send/:index" do
    active_log
    filename = params[:filename]
    log = Store.find(filename, "logs")
    @operations = Log.new(log).convert_to_operations
    operation = @operations[params[:index].to_i]

    operation.execute(filename)
    redirect :"logs/operations/#{filename}"
  end

  def active_log
    @logs_active = "active"
    @bods_active = ""
    @welcome_active = ""
  end
end
