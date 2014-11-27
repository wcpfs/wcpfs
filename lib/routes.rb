$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'games'
require 'fileutils'
require 'sprockets'
require "yui/compressor"

class Routes < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]

  set :bind, '0.0.0.0'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  configure do 
    register Sinatra::CrossOrigin
    set :logging, true
    set :assets, (Sprockets::Environment.new { |env|
      env.append_path(settings.root + "/assets/images")
      env.append_path(settings.root + "/assets/javascripts")
      env.append_path(settings.root + "/assets/stylesheets")
      env.append_path("spec/javascripts")

      # compress everything in production
      if ENV["RACK_ENV"] == "production"
        env.js_compressor  = YUI::JavaScriptCompressor.new
        env.css_compressor = YUI::CssCompressor.new
      end
    })
  end
  
  get "/app.js" do
    content_type("application/javascript")
    settings.assets["app.js"]
  end

  get "/SpecHelper.js" do
    content_type("application/javascript")
    settings.assets["SpecHelper.js"]
  end

  get "/app.css" do
    content_type("text/css")
    settings.assets["app.css"]
  end

  before '/gm/*' do
    login_check
  end

  before '/user/*' do
    login_check
  end

  before '/games/*' do
    cross_origin
  end

  def login_check
    if session[:user_id].nil?
      session[:redirect_path] = request.fullpath
      redirect to('/login') 
    end
  end

  get '/testmail' do
    mail_client.send_join_game({:title => 'Quest for Perfection Part I', :datetime => 1234567890000, :gm_pic => "", :gameId => "8b91a3cc-8669-44ae-bf40-0dad6e11d373", :notes => "This is a note that you may care about as a player"}, {:email => "alexdisney@gmail.com"})
  end

  get '/' do
    File.read(File.dirname(__FILE__) + '/../public/index.html')
  end

  get '/games' do
    cross_origin
    content_type :json
    settings.games.current.to_json
  end

  get '/games/detail' do
    games.find(params[:gameId]).to_json
  end

  get '/game/:gameId/:asset' do
    content_type :png
    File.read("game_assets/#{params[:gameId]}/#{params[:asset]}")
  end
  
  get '/ping' do
    "pong"
  end

  get '/login' do
    if params[:redirect_path]
      session[:redirect_path] = params[:redirect_path] 
    end
    if session[:user_id]
      if session[:redirect_path]
        redirect to(session[:redirect_path])
      else
        redirect to('/')
      end
    else
      redirect google.auth_url(to('/oauth2callback')), 303
      redirect to('/')
    end
  end

  get '/oauth2callback' do
    google.save_credentials(session, params[:code])
    profile = google.profile(session)
    session[:user_id] = users.ensure(profile)[:id]

    if session[:redirect_path]
      redirect to(session[:redirect_path]) 
    else
      redirect to('/')
    end
  end

  get '/user/subscribe' do
    users.subscribe(user[:id])
    message("You are subscribed to new game notifications.")
  end

  get '/user/unsubscribe' do
    message("You are unsubscribed from new game notifications.")
  end

  get '/user/info' do
    user.to_json
  end

  post '/user/info' do
    users.update(user[:id], JSON.parse(request.body.read, :symbolize_names => true)).to_json
  end

  get '/user/games' do
    games.for_user(user).to_json
  end

  get '/user/joinGame' do
    success = games.signup(params[:gameId], {
      name: user[:name],
      email: user[:email]
    })
    mail_client.send_join_game(games.find(params[:gameId]), user) if success
    redirect to('/')
  end

  get '/gm/prep' do
    content_type :json
    File.read('gm_prep.json')
  end

  post '/gm/createGame' do
    game_info = {
      gm_name: user[:name],
      gm_pic: user[:pic],
      gm_id: user[:id],
      datetime: params[:datetime].to_i,
      title: params[:title],
      notes: params[:notes]
    }
    item = games.create game_info
    mail_client.send_new_game(item, users.subscriptions)
    redirect("/#gmDetail-#{item[:gameId]}")
  end

  post '/gm/game' do
    games.update(user[:id], JSON.parse(request.body.read, :symbolize_names => true)).to_json
  end

  private

  def message(msg)
    redirect to("/#message-#{URI.encode(msg)}")
  end

  def google
    settings.google
  end

  def games
    settings.games
  end

  def users
    settings.users
  end

  def mail_client
    settings.mail_client
  end

  def user
    users.find(session[:user_id])
  end
end