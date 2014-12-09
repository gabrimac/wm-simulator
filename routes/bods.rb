class App < Sinatra::Application

  post "/bods/create" do
    active_bod
    content = params[:bod][:text] if params[:bod][:text]
    name = params[:bod][:name] if params[:bod][:name]

    store = Store.new(name, content, "bod")

    redirect "/bods/index" if store.save
    haml :'bods/new'
  end

  get "/bods/new" do
    active_bod
    haml :'bods/new'
  end

  get "/bods/index" do
    active_bod
    @bods = Store.all("bods")

    haml :'bods/index'
  end

  def active_bod
    @welcome_active = ""
    @logs_active = ""
    @bods_active = "active"
  end
end
