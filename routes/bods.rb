class App < Sinatra::Application

  post "/bods/create" do
    content = params[:bod][:text] if params[:bod][:text]
    name = params[:bod][:name] if params[:bod][:name]

    store = Store.new(name, content, "bod")

    redirect "/bods/index" if store.save
    haml :'bods/new'
  end

  get "/bods/new" do
    haml :'bods/new'
  end

  get "/bods/index" do
    @bods = Store.all("bods")

    haml :'bods/index'
  end
end
