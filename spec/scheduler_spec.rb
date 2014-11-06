ENV["RACK_SECRET"] = 'not the real secret'
ENV["RACK_ENV"] = 'test'

require 'scheduler'
require 'rack/test'
require 'google_api'

describe SchedulerApp do
  include Rack::Test::Methods

  let (:games) { double Games}
  let (:google) { double GoogleApi}
  let (:app) { SchedulerApp.new }

  before( :each ) do
    SchedulerApp.set :games, games
    SchedulerApp.set :google, google
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
    expect(last_response.status).to be 302
    follow_redirect!
    expect(last_request.url).to eq 'http://example.org/login'
  end

  it "/login redirects to / if a user is already authenticated"

  describe 'when a GM is authenticated' do
    let(:env){ Hash.new }
    let(:google_profile) {{
      "kind"=>"plus#person", 
      "etag"=>"\"MoxPKeu0NQD8g5Gtts3ebh50504/d_d3uSVxv_l3CdC82BuxhNOI9sU\"", 
      "occupation"=>"Senior Software Developer", 
      "gender"=>"male", 
      "urls"=>[], 
      "objectType"=>"person", 
      "id"=>"113769764833315172586", 
      "displayName"=>"Ben Rady", 
      "name"=>{"familyName"=>"Rady", "givenName"=>"Ben"}, 
      "aboutMe"=>"", 
      "url"=>"https://plus.google.com/+BenRady", 
      "image"=>{
        "url"=>"https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50", "isDefault"=>false
      }, 
      "isPlusUser"=>true, 
      "language"=>"en", 
      "verified"=>false, "cover"=>{}
    }}

    before :each do
      env['rack.session'] = { :user => google_profile}
    end

    it "can return the GM's info object as json" do
      get '/gm/info', {}, env
      expect(JSON.parse(last_response.body)).to include({
        "displayName" => "Ben Rady"
      })
    end

    it "can create a new game" do
      expect(games).to receive(:create).with({
        gm_name: "Ben Rady", 
        gm_id: "113769764833315172586",
        gm_pic: google_profile["image"]["url"],
        datetime: 123456789000, 
        title: "Title", 
        notes: "My Notes"}).
        and_return( {gameId: 'abc123'} )

      post '/gm/createGame', {title: "Title", datetime: 123456789000, notes: "My Notes" }, env
      expect(last_response.status).to eq 302
      follow_redirect!
      expect(last_request.url).to eq 'http://example.org/'
    end
  end
end
