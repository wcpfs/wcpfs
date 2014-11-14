ENV["RACK_SECRET"] = 'not the real secret'
ENV["RACK_ENV"] = 'test'

require 'scheduler'
require 'rack/test'
require 'google_api'
require 'users'
require 'games'
require 'mail_client'
require 'google_api'

describe SchedulerApp do
  include Rack::Test::Methods

  let (:games) { double Games }
  let (:users) { double Users } 
  let (:google) { double GoogleApi }
  let (:mail_client) { double MailClient }
  let (:app) { SchedulerApp.new }

  before( :each ) do
    SchedulerApp.set :games, games
    SchedulerApp.set :google, google
    SchedulerApp.set :users, users
    SchedulerApp.set :mail_client, mail_client
  end

  def expect_redirect_to path, code=302
    expect(last_response.status).to eq code
    follow_redirect!
    expect(last_request.url).to eq "http://example.org#{path}"
  end
  
  it "can play ping pong" do
    get '/ping'
    expect(last_response.body).to eq "pong"
  end

  it "can get a list of games" do
    game_list = [{title: "My Game"}]
    allow(games).to receive(:all) { game_list }
    get '/games'
    expect(JSON.parse(last_response.body, :symbolize_names => true)).to eq game_list
  end

  it "can get an individual game" do
    game = {title: "My Game"}
    expect(games).to receive(:find).with('abc123') { game }
    get 'games/detail', {gameId: 'abc123'}
    expect(last_response.body).to eq game.to_json
  end

  it "allows cross origin requests" do
    allow(games).to receive(:all) { [] }
    get '/games', {}, {"HTTP_ORIGIN" => "http://myapp.com"}
    expect(last_response.headers).to include({ "Access-Control-Allow-Origin" => "http://myapp.com"})
  end

  it "redirects to login when accessing GM content" do
    expect(google).to receive(:auth_url) { "http://google/auth" }
    get '/gm/createGame'
    expect_redirect_to '/login'
  end

  describe "with a session" do
    let(:env){ Hash.new }
    let (:session) { Hash.new }

    before :each do
      env['rack.session'] = session
    end

    it "sets a redirect URL when redirecting to login" do
      expect(google).to receive(:auth_url) { "http://google/auth" }
      get '/user/info?key=value', {}, env
      expect_redirect_to '/login'
      expect(last_request.env['rack.session'][:redirect_path]).to eq("/user/info?key=value")
    end

    it "/login can set a redirect_path param" do
      expect(google).to receive(:auth_url) { "http://google/auth" }
      get '/login', {:redirect_path => '/user/info%3Fkey%3Dvalue'}, env
      expect(last_request.env['rack.session'][:redirect_path]).to eq("/user/info%3Fkey%3Dvalue")
    end

    describe "when authenticating" do
      before( :each ) do
        allow(google).to receive(:save_credentials)
        allow(google).to receive(:profile)
        allow(users).to receive(:ensure)
      end

      it "saves the api code to the session" do
        expect(google).to receive(:save_credentials).with(hash_including(:session_id), 'abc123')
        get '/oauth2callback', {:code => 'abc123'}, env
      end

      it "save the user profile to dynamo" do
        profile = {}
        allow(google).to receive(:profile) {profile}
        expect(users).to receive(:ensure).with(profile)
        get '/oauth2callback', {:code => 'abc123'}, env
      end
      
      it "redirects to saved redirect path when login complete" do
        session[:redirect_path] = '/foo'
        get '/oauth2callback', {}, env
        expect_redirect_to '/foo'
      end

      it "redirects to root if no redirect path set" do
        get '/oauth2callback', {}, env
        expect_redirect_to '/'
      end
    end
  end

  describe 'when a user is authenticated' do
    let(:env){ Hash.new }
    let (:user_info) {fake_user_info}

    before :each do
      env['rack.session'] = { :user => user_info}
    end

    it "can return the GM's info object as json" do
      get '/user/info', {}, env
      expect(JSON.parse(last_response.body, :symbolize_names => true)).to include({
        name: "Ben Rady",
        email: "benrady@gmail.com"
      })
    end

    it "/login will redirect to the specified url" do
      get '/login', {:redirect_path => '/%23newGame'}, env
      expect_redirect_to '/%23newGame'
    end

    it "can subscribe to new game updates" do
      expect(users).to receive(:subscribe).with('benrady@gmail.com')
      get '/user/subscribe', {}, env
    end

    describe "when creating a game" do
      before( :each ) do
        allow(users).to receive(:subscriptions) { [:fake_user_list] }
      end
      
      it "saves the game to the DB" do
        allow(mail_client).to receive(:send_new_game)
        expect(games).to receive(:create).with(fake_new_game).and_return( {gameId: 'abc123'} )

        post '/gm/createGame', {title: "Title", datetime: 123456789000, notes: "My Notes" }, env
        expect_redirect_to '/'
      end

      it "notifies subscribed players" do
        allow(games).to receive(:create) {{ "gameId" => "abc123" }}
        expect(mail_client).to receive(:send_new_game).with(hash_including("gameId" => "abc123"), [:fake_user_list])
        post '/gm/createGame', {title: "Title", datetime: 123456789000, notes: "My Notes" }, env
      end
    end


    it "can instantly join a game" do
      expect(games).to receive(:signup).with("abc123", {name: "Ben Rady", email: 'benrady@gmail.com'})
      get '/user/joinGame', {gameId: 'abc123'}, env
      expect_redirect_to '/'
    end

    it "redirects /login to /" do
      expect(google).not_to receive(:auth_url)
      get '/login', {}, env
      expect_redirect_to '/'
    end
  end
end