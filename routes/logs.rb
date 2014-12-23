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

  get "/logs/load" do
    active_log
    haml :'logs/load'
  end

  get "/logs/index" do
    active_log
    session['responses'] = []
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

  post "/logs/download" do
    active_log
    name = params[:log][:name] if params[:log][:name]
    content = params[:log][:body] if params[:log][:body]

    store = Store.new(name, content, "logs")

    redirect "/logs/index" if store.save
    haml :'logs/index_parser'
  end

  post "/logs/operations_parser/" do
    active_log
    @filename = params[:log][:filename]
    @bod = params[:log][:bod_id]
    log = Store.find(@filename, "logs")
    @responses = Response.find(@filename)
    parser_log = ParserLog.new(log, @bod).convert_to_operations
    @operations = parser_log.log_bod

    haml :'logs/operations_parser'
  end

  get "/logs/operations/:filename/send/:index" do
    active_log
    session['responses'] << params[:index].to_i
    filename = params[:filename]
    log = Store.find(filename, "logs")
    @operations = Log.new(log).convert_to_operations
    operation = @operations[params[:index].to_i]

    operation.execute(filename)
    redirect :"logs/operations/#{filename}"
  end

  def session_responses

  end

  def active_log
    @logs_active = "active"
    @bods_active = ""
    @welcome_active = ""
  end
end
