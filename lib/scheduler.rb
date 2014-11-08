$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'games'

class SchedulerApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]

  set :bind, '0.0.0.0'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  configure do 
    register Sinatra::CrossOrigin
    set :logging, true
  end

  before '/gm/*' do
    redirect to('/login') unless session[:user]
  end

  before '/users/*' do
    redirect to('/login') unless session[:user]
  end

  before '/games/*' do
    cross_origin
  end

  get '/testmail' do
    mail_client.send_new_game({"title" => 'test'}, [])
  end

  get '/' do
    File.read(File.dirname(__FILE__) + '/../public/index.html')
  end

  get '/games' do
    cross_origin
    content_type :json
    settings.games.all.to_json
  end
  
  get '/ping' do
    "pong"
  end

  get '/login' do
    unless session[:user]
      redirect google.auth_url(to('/oauth2callback')), 303
    end
    redirect to('/')
  end

  get '/oauth2callback' do
    google.save_credentials(session, params[:code])
    profile = google.profile(session)
    session[:user] = users.ensure(profile)

    # Could create a redirect loop
    redirect to('/login')
  end

  get '/user/subscribe' do
    users.subscribe(user[:email])
    message("You are subscribed to new game notifications.")
  end

  get '/user/unsubscribe' do
    message("You are unsubscribed from new game notifications.")
  end

  get '/user/info' do
    session[:user].to_json
  end

  get '/user/joinGame' do
    games.signup(params[:gameId], {
      name: user[:name],
      email: user[:email]
    })
    redirect to('/')
  end

  post '/gm/createGame' do
    game_info = {
      'gm_name' => user[:name],
      'gm_pic' => user[:pic],
      'gm_id' => user[:id],
      'datetime' => params[:datetime].to_i,
      'title' => params[:title],
      'notes' => params[:notes]
    }
    item = games.create game_info
    mail_client.send_new_game(game_info, users.subscriptions)
    content_type :json
    redirect('/')
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
    session[:user]
  end
end
