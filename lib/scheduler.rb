$LOAD_PATH << File.join(Dir.getwd, 'lib')

require 'sinatra'
require 'json'
require 'rack/openid'

class SchedulerApp < Sinatra::Base
  use Rack::Session::Cookie, :secret => ENV["RACK_SECRET"]
  use Rack::OpenID

  set :bind, '0.0.0.0'

  configure do # could also just be :production
    set :logging, true
  end

  #get '/subscribe' do
  #  puts params[:email]
  #end

  #get '/unsubscribe' do
  #  puts params[:email]
  #end

  #get '/games' do
  #  "Returns the list of games as JSON"
  #end
  
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
          :identifier => "https://www.google.com/accounts/o8/id",
          :required => ["http://axschema.org/contact/email",
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
end
