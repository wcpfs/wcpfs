ENV["RACK_SECRET"] = 'not the real secret'
ENV["RACK_ENV"] = 'test'

require 'scheduler'
require 'rack/test'

describe SchedulerApp do
  include Rack::Test::Methods

  let (:games) { double Games}
  let (:app) { SchedulerApp.new }

  before( :each ) do
    SchedulerApp.set :games, games
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

  it "redirects to login when accessing GM content" do
    expect(Rack::OpenID).to receive(:build_header).with({
      :identifier => "https://www.google.com/accounts/o8/id",
      :required => ["http://axschema.org/contact/email",
                    "http://axschema.org/namePerson/first",
                    "http://axschema.org/namePerson/last"],
                    :method => 'POST'
    }).and_return "header"
    get '/gm/info'
    expect(last_response.status).to be 401
    expect(last_response.headers['WWW-Authenticate']).to eq "header"
  end

  describe 'when a GM is authenticated' do
    let(:env){ Hash.new }
    before :each do
      env['rack.session'] = {
        :user => {
          :first_name => 'Ben',
          :last_name => 'Rady',
          :email => 'benrady@gmail.com'
        }}
    end

    it "can return the GM's info object as json" do
      get '/gm/info', {}, env
      expect(JSON.parse(last_response.body)).to include({
        "first_name" => "Ben"
      })
    end

    it "can create a new game" do
      expect(games).to receive(:create).with({
        GM: "benrady@gmail.com", 
        datetime: 123456789000, 
        title: "Title", 
        notes: "My Notes"}).
        and_return( {gameId: 'abc123'} )

      post '/gm/createGame', {title: "Title", datetime: 123456789000, notes: "My Notes" }, env
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to include({
        "gameId" => "abc123"
      })
    end
  end
end
