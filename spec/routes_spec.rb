ENV["RACK_SECRET"] = 'not the real secret'
ENV["RACK_ENV"] = 'test'

require 'rack/test'
require 'routes'
require 'google_api'
require 'users'
require 'games'
require 'mail_client'
require 'google_api'

describe Routes do
  include Rack::Test::Methods

  let (:games) { double Games }
  let (:users) { double Users } 
  let (:google) { double GoogleApi }
  let (:mail_client) { double MailClient }
  let (:app) { Routes.new }

  before( :each ) do
    Routes.set :games, games
    Routes.set :google, google
    Routes.set :users, users
    Routes.set :mail_client, mail_client
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

  it "can serve up compressed javascript" do
    get 'app.js'
    expect(last_response.body).to match /function homeView\(\)/
  end

  it "can serve up a spec helper" do
    get 'SpecHelper.js'
    expect(last_response.body).to match /describe\('WCPFS',/
  end

  it "can get a list of games" do
    game_list = [{title: "My Game"}]
    allow(games).to receive(:current) { game_list }
    get '/games'
    expect(JSON.parse(last_response.body, :symbolize_names => true)).to eq game_list
  end

  it "can get an individual game" do
    game = {title: "My Game"}
    expect(games).to receive(:find).with('abc123') { game }
    get 'games/detail', {id: 'abc123'}
    expect(last_response.body).to eq game.to_json
  end

  it "can fetch a game asset" do
    expect(File).to receive(:read).with('game_assets/abc123/chronicle.png')
    get 'game/abc123/chronicle.png'
  end

  it "allows cross origin requests" do
    allow(games).to receive(:current) { [] }
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
        allow(users).to receive(:ensure) { fake_user_info }
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
      allow(users).to receive(:find) { user_info }
      env['rack.session'] = { :user_id => user_info[:id] }
    end

    it "can update user info" do
      expect(users).to receive(:update).with(user_info[:id], {}) { {} }
      post '/user/info', '{}', env
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq '{}'
    end

    it "can cancel an individual game" do
      expect(games).to receive(:cancel).with(fake_user_info[:id], 'abc123') 
      delete 'games/detail', {gameId: 'abc123'}
      expect(last_response.status).to eq 200
    end

    it "can return the GM's info object as json" do
      get '/user/info', {}, env
      expect(JSON.parse(last_response.body, :symbolize_names => true)).to include({
        name: "Ben Rady",
        email: "benrady@gmail.com"
      })
    end

    it "can return the player's games" do
      expect(games).to receive(:for_user).with(user_info) {{
        playing: [],
        running: []
      }}
      get '/user/games', {}, env
      expect(JSON.parse(last_response.body, :symbolize_names => true)).to eq({
        playing: [],
        running: []
      })
    end

    it "can get the users signature and initals image" do
      pending "Not sure how to test async"
      get '/user/signature', {}, env
      expect(last_response.headers["Content-Type"]).to equal('image/png')
    end

    it "can update a game" do
      expect(games).to receive(:update).with(user_info[:id], {}) { {} }
      post '/gm/game', '{}', env
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq '{}'
    end

    it "can send a chronicle sheet to the users in a game" do
      encoded_data = Base64.encode64("Hello PNG")
      expect(games).to receive(:send_chronicle).with(fake_user_info, 'abc123', "Hello PNG")
      post '/gm/sendChronicle', {id:"abc123",imgBase64:"data:image/png;base64,#{encoded_data}"}, env
    end

    it "/login will redirect to the specified url" do
      get '/login', {:redirect_path => '/%23newGame'}, env
      expect_redirect_to '/%23newGame'
    end

    it "can subscribe to new game updates" do
      expect(users).to receive(:subscribe).with(user_info[:id])
      get '/user/subscribe', {}, env
    end

    describe "when creating a game" do
      before( :each ) do
        allow(users).to receive(:subscriptions) { [:fake_user_list] }
        allow(mail_client).to receive(:send_join_game)
        allow(games).to receive(:add_discussion_thread_id)
      end
      
      it "saves the game to the DB" do
        allow(mail_client).to receive(:send_new_game)
        expect(games).to receive(:create).with(fake_new_game).and_return( {id: 'abc123'} )

        post '/gm/createGame', {title: "City of Golden Death!", datetime: 1234567890000, notes: "My Notes" }, env
        expect_redirect_to '/'
      end

      it "notifies subscribed players" do
        allow(games).to receive(:create) {{ "id" => "abc123" }}
        expect(mail_client).to receive(:send_new_game).with(hash_including("id" => "abc123"), [:fake_user_list])
        post '/gm/createGame', {title: "City of Golden Death!", datetime: 1234567890000, notes: "My Notes" }, env
      end

      it "does not send notification if private game" do
        allow(games).to receive(:create) {{ "id" => "abc123" }}
        expect(mail_client).to_not receive(:send_new_game).with(hash_including("id" => "abc123"), [:fake_user_list])
        post '/gm/createGame', {title: "City of Golden Death!", datetime: 1234567890000, notes: "My Notes", private: true }, env
      end

      it "sends the initial discussion email to the GM" do
        allow(games).to receive(:create) {fake_saved_game}
        allow(mail_client).to receive(:send_new_game)
        expect(mail_client).to receive(:send_join_game).with(fake_saved_game, user_info) { "mailId" }
        expect(games).to receive(:add_discussion_thread_id).with(fake_saved_game[:id], "mailId")
        post '/gm/createGame', {title: "City of Golden Death!", datetime: 1234567890000, notes: "My Notes" }, env
      end
    end

    describe "joining" do
      let (:game) { double "game" }
      
      before( :each ) do
        allow(games).to receive(:find) { game }
        allow(games).to receive(:signup) { true }
        allow(games).to receive(:add_discussion_thread_id)
        allow(mail_client).to receive(:send_join_game) { 'mailId' }
      end

      it "can join a game" do
        expect(games).to receive(:signup).with("abc123", {name: "Ben Rady", email: 'benrady@gmail.com'})
        get '/user/joinGame', {id: 'abc123'}, env
        expect_redirect_to '/'
      end

      it "can leave a game" do
        expect(games).to receive(:leave).with("abc123", {name: "Ben Rady", email: 'benrady@gmail.com'})
        get '/user/leaveGame', {id: 'abc123'}, env
        expect_redirect_to '/'
      end
      
      it "sends an email to joining player on success" do
        expect(mail_client).to receive(:send_join_game).with(game, fake_user_info)
        get '/user/joinGame', {id: 'abc123'}, env
      end

      it "does not send an email on failure" do
        allow(games).to receive(:signup) { false }
        expect(mail_client).to_not receive(:send_join_game)
        get '/user/joinGame', {id: 'abc123'}, env
      end

      it "tracks sent mail ids" do
        expect(games).to receive(:add_discussion_thread_id).with('abc123', 'mailId')
        get '/user/joinGame', {id: 'abc123'}, env
      end
    end

    it "redirects /login to /" do
      expect(google).not_to receive(:auth_url)
      get '/login', {}, env
      expect_redirect_to '/'
    end
  end
end
