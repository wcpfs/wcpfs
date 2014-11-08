require 'games'
require 'aws-sdk'

describe Games do
  let (:client) { double Aws::DynamoDB::Client }
  let (:games) { Games.new client, 'games-table' }

  before( :each ) do
    allow(SecureRandom).to receive(:uuid) { "abc123" }
    allow(client).to receive :put_item
  end

  describe "when creating games" do
    it "saves them to DynamoDB" do
      item = { 'title' => "Fake Game" }
      games.create(item)
      expect(client).to have_received(:put_item).with(hash_including({
        table_name: "games-table", 
        item: item.merge('gameId' => "abc123", 'seats' => [])
      }))
    end

    it "removes notes field if empty" do
      item = { 'notes' => '' }
      games.create(item)
      expect(client).to have_received(:put_item).with(hash_including({
        table_name: "games-table", 
        item: {'gameId' => "abc123", 'seats' => []}
      }))
    end

    it "ensures the datetime field is an integer"
  end

  describe "after a game is created" do
    it "can sign up for that game" do
      resp = spy('resp')
      item = { "gameId" => 'abc123', "seats" => [] }
      items = [item]
      expect(resp).to receive(:items) { items }
      allow(client).to receive(:scan) { resp }
      games.signup('abc123', {name: "Bob"})
      expect(client).to have_received(:put_item).with({
        table_name: "games-table", 
        item: {"gameId" => "abc123", "seats" => [{:name => "Bob"}]}
      })
    end
  end

  describe "when fetching games" do
    it "can list the existing games" do
      resp = spy('resp')
      items = [:items]
      expect(resp).to receive(:items) { items }
      allow(client).to receive(:scan) { resp }
      expect(games.all).to eq items
    end

    it "removes domain names from emails"

    it "ensures datetime field is an integer"
  end

  it "caches the game list" do
    allow(client).to receive(:scan) { spy ('resp') }
    games.all
    expect(client).to_not receive(:scan)
    games.all
  end

  it "updating the games invalidates the cache" do
    allow(client).to receive(:scan) { spy ('resp') }
    allow(client).to receive(:put_item) 
    games.all
    games.create({})

    expect(client).to receive(:scan) { spy('resp') }
    games.all
  end
end
