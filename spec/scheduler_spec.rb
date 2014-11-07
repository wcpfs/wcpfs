ENV["RACK_SECRET"] = 'not the real secret'
ENV["RACK_ENV"] = 'test'

require 'scheduler'
require 'rack/test'
require 'google_api'
require 'users'
require 'games'
require 'google_api'

describe SchedulerApp do
  include Rack::Test::Methods

  let (:games) { double Games }
  let (:users) { double Users } 
  let (:google) { double GoogleApi }
  let (:app) { SchedulerApp.new }

  before( :each ) do
    SchedulerApp.set :games, games
    SchedulerApp.set :google, google
    SchedulerApp.set :users, users
  end

  def expect_redirect_to path
    expect(last_response.status).to eq 302
    follow_redirect!
    expect(last_request.url).to eq "http://example.org#{path}"
  end
  
  it "can play ping pong" do
    get '/ping'
    expect(last_response.body).to eq "pong"
  end

  it "can get a list of games" do
    game_list = [{"title" => "My Game"}]
    allow(games).to receive(:all) { game_list }
    get '/games'
    expect(JSON.parse(last_response.body)).to eq game_list
  end

  it "allows cross origin requests" do
    allow(games).to receive(:all) { [] }
    get '/games', {}, {"HTTP_ORIGIN" => "http://myapp.com"}
    expect(last_response.headers).to include({ "Access-Control-Allow-Origin" => "http://myapp.com"})
  end

  it "redirects to login when accessing GM content" do
    expect(google).to receive(:auth_url) { "http://google/auth" }
    get '/gm/info'
    expect_redirect_to '/login'
  end

  describe 'when a user is authenticated' do
    let(:env){ Hash.new }
    let (:user_info) {{
      email: 'benrady@gmail.com',
      name: "Ben Rady",
      pic: "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
      id: "google-113769764833315172586"
    }}

    before :each do
      env['rack.session'] = { :user => user_info}
    end

    it "can return the GM's info object as json" do
      get '/gm/info', {}, env
      expect(JSON.parse(last_response.body)).to include({
        "name" => "Ben Rady"
      })
    end

    it "can create a new game" do
      expect(games).to receive(:create).with({
        gm_name: "Ben Rady", 
        gm_id: "google-113769764833315172586",
        gm_pic: user_info[:pic],
        datetime: 123456789000, 
        title: "Title", 
        notes: "My Notes"}).
        and_return( {gameId: 'abc123'} )

      post '/gm/createGame', {title: "Title", datetime: 123456789000, notes: "My Notes" }, env
      expect_redirect_to '/'
    end

    it "can instantly join a game" do
      expect(games).to receive(:signup).with("abc123", {name: "Ben Rady", email: 'benrady@gmail.com'})
      get '/gm/joinGame', {gameId: 'abc123'}, env
      expect_redirect_to '/'
    end

    it "redirects /login to /" do
      expect(google).not_to receive(:auth_url)
      get '/login', {}, env
      expect_redirect_to '/'
    end
  end
end
