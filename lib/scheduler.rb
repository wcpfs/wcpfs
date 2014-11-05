$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'google/api_client'
require 'games'

class GoogleApi
  attr_reader :client

  def initialize
    @client = Google::APIClient.new(application_name: "Windy City Pathfinder", application_version: "v1")
    @client.authorization.client_id = ENV["GOOGLE_CLIENT_ID"]
    @client.authorization.client_secret = ENV["GOOGLE_CLIENT_SECRET"]
    @client.authorization.scope = 'profile'
    @plus = @client.discovered_api('plus')
  end

  def profile(session)
    auth = @client.authorization.dup
    auth.update_token!(session)
    result = @client.execute(:api_method => @plus.people.get,
                            :parameters => {'userId' => 'me'},
                            :authorization => auth)
    result.data.to_hash
  end

  def save_credentials(session, code)
    auth = @client.authorization.dup
    auth.code = code if code
    auth.fetch_access_token!
    session[:access_token] = auth.access_token
    session[:refresh_token] = auth.refresh_token
    session[:expires_in] = auth.expires_in
    session[:issued_at] = auth.issued_at
  end

  def auth_url(redirect_uri)
    @client.authorization.redirect_uri = redirect_uri
    @client.authorization.authorization_uri.to_s
  end
end

class SchedulerApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]

  set :bind, '0.0.0.0'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  configure do 
    register Sinatra::CrossOrigin
    set :logging, true

    google_api = GoogleApi.new

    set :google, google_api
  end

  def google
    settings.google
  end

  def user_credentials
    # They say: "Build a per-request oauth credential based on token stored in session
    # which allows us to use a shared API client."
    #
    # I don't get how storing this thing allows multiple users to log in.
    @authorization ||= (
      auth = google.client.authorization.dup
      auth.redirect_uri = to('/oauth2callback')
      auth.update_token!(session)
      auth
    )
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
    unless session[:access_token]
      redirect google.auth_url(to('/oauth2callback')), 303
    end
    unless session[:user]
      session[:user] = google.profile(user_credentials)
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
