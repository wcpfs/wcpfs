$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'json'
require 'rack/openid'
require 'games'

class SchedulerApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]
  use Rack::OpenID

  set :bind, '0.0.0.0'

  configure do # could also just be :production
    set :logging, true
  end

  get '/games/subscribe' do
    "Subscribed #{params[:email]}"
  end

  get '/games/unsubscribe' do
    "Unsubscribed #{params[:email]}"
  end

  get '/games' do
    content_type :json
    settings.games.all.to_json
  end
  
  get '/ping' do
    "pong"
  end

  before '/gm/*' do
    if resp = request.env["rack.openid.response"]
      if resp.status == :success
        fields = resp.get_signed_ns("http://openid.net/srv/ax/1.0")
        session[:user] = {
          :first_name => fields['value.ext1'],
          :last_name => fields['value.ext2'],
          :email => fields['value.ext0']
        }
        redirect request.path
      end
    else
      if not session[:user]
        response.headers['WWW-Authenticate'] = Rack::OpenID.build_header(
          identifier: "https://www.google.com/accounts/o8/id",
          required:  ["http://axschema.org/contact/email",
                        "http://axschema.org/namePerson/first",
                         "http://axschema.org/namePerson/last"],
                        :method => 'POST')
        throw :halt, [401, 'got openid?']
      end
    end
  end

  get '/gm/info' do
    if session[:user]
      session[:user].to_json
    else
      "{}"
    end
  end

  # ?title=My%20Game&datetime=123456789000&notes=These%20Are%20My%20Notes
  post '/gm/createGame' do
    game_info = {
      GM: gm_email,
      datetime: params[:datetime].to_i,
      title: params[:title],
      notes: params[:notes]
    }
    settings.games.create game_info
    redirect '/games?id=abc123'
  end

  private

  def gm_email
    session[:user][:email]
  end
end
