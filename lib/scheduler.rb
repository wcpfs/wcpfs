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
    # Ensure user has authorized the app
    redirect to('/login') unless session[:user]
  end

  get '/' do
    #Only used for testing
    File.read(File.dirname(__FILE__) + '/../public/index.html')
  end

  get '/login' do
    unless session[:user]
      redirect google.auth_url(to('/oauth2callback')), 303
    end
    redirect to('/')
  end

  get '/oauth2callback' do
    google.save_credentials(session, params[:code])
    session[:user] = google.profile(session)

    # Could create a redirect loop
    redirect to('/login')
  end

  before '/games/*' do
    cross_origin
  end

  get '/games/subscribe' do
    #"Subscribed #{params[:email]}"
    redirect to("/#subscribed")
  end

  get '/games/unsubscribe' do
    #"Unsubscribed #{params[:email]}"
    redirect to("/#unsubscribed")
  end

  get '/games' do
    cross_origin
    content_type :json
    settings.games.all.to_json
  end
  
  get '/ping' do
    "pong"
  end

  get '/gm/info' do
    session[:user].to_json
  end

  get '/gm/joinGame' do
    games.signup(params[:gameId], {
      name: user_name
      #email: user_email
    })
    redirect to('/')
  end

  # ?title=My%20Game&datetime=123456789000&notes=These%20Are%20My%20Notes
  post '/gm/createGame' do
    game_info = {
      gm_name: user_name,
      gm_pic: session[:user]["image"]["url"],
      gm_id: session[:user]["id"],
      datetime: params[:datetime].to_i,
      title: params[:title],
      notes: params[:notes]
    }
    item = games.create game_info
    content_type :json
    redirect('/')
  end

  private

  def google
    settings.google
  end

  def games
    settings.games
  end

  def user_name
    session[:user]["displayName"]
  end

end
