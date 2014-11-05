$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'google/api_client'
require 'games'

class SchedulerApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]

  set :bind, '0.0.0.0'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  configure do 
    register Sinatra::CrossOrigin
    set :logging, true

    client = Google::APIClient.new
    client.authorization.client_id = ENV["GOOGLE_CLIENT_ID"]
    client.authorization.client_secret = ENV["GOOGLE_CLIENT_SECRET"]
    client.authorization.scope = 'profile'
    oauth2_api = client.discovered_api('plus')

    set :api_client, client
    set :oauth2_api, oauth2_api
  end

  def api_client
    settings.api_client
  end

  def oauth2_api
    settings.oauth2_api
  end

  def user_credentials
    # Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client.
    @authorization ||= (
      auth = api_client.authorization.dup
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
      auth
    )
  end

  before '/gm/*' do
    # Ensure user has authorized the app
    redirect to('/login') unless session[:user]
  end

  after do
    # Serialize the access/refresh token to the session
    session[:access_token] = user_credentials.access_token
    session[:refresh_token] = user_credentials.refresh_token
    session[:expires_in] = user_credentials.expires_in
    session[:issued_at] = user_credentials.issued_at
  end

  get '/' do
    #Only used for testing
    File.read(File.dirname(__FILE__) + '/../public/index.html')
  end

  get '/login' do
    unless user_credentials.access_token || request.path_info =~ /^\/oauth2/
      redirect to('/oauth2authorize')
    end
    unless session[:user]
      result = api_client.execute(:api_method => oauth2_api.people.get,
                              :parameters => {'userId' => 'me'},
                              :authorization => user_credentials)
      puts session[:user] = result.data.to_hash
    end
    redirect to('/')
  end

  get '/oauth2authorize' do
    redirect user_credentials.authorization_uri.to_s, 303
  end

  get '/oauth2callback' do
    # Exchange token
    user_credentials.code = params[:code] if params[:code]
    user_credentials.fetch_access_token!
    redirect to('/login')
  end

  before '/games/*' do
    cross_origin
  end

  get '/games/subscribe' do
    "Subscribed #{params[:email]}"
  end

  get '/games/unsubscribe' do
    "Unsubscribed #{params[:email]}"
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

  # ?title=My%20Game&datetime=123456789000&notes=These%20Are%20My%20Notes
  post '/gm/createGame' do
    game_info = {
      gm_name: session[:user]["displayName"],
      gm_pic: session[:user]["image"]["url"],
      gm_id: session[:user]["id"],
      datetime: params[:datetime].to_i,
      title: params[:title],
      notes: params[:notes]
    }
    item = settings.games.create game_info
    content_type :json
    item.to_json
  end
end
