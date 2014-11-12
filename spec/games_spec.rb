require 'games'
require 'aws_client'

describe Games do
  let (:client) { double AwsClient::Connection }
  let (:table) { double AwsClient::Table }
  let (:games) { Games.new client }
  let (:items) { [] }

  before( :each ) do
    allow(SecureRandom).to receive(:uuid) { "abc123" }
    allow(client).to receive(:table) { table }
    allow(table).to receive(:all) { items }
  end

  it "can list the existing games" do
    expect(games.all).to be items
  end

  describe "when creating games" do
    let (:saved_game) {fake_new_game_no_notes.merge(gameId: "abc123", seats: [])}

    it "saves them to DynamoDB" do
      expect(table).to receive(:save).with(fake_new_game.merge(saved_game))
      games.create(fake_new_game)
    end

    it "removes notes field if empty" do
      expect(table).to receive(:save).with(saved_game)
      games.create(fake_new_game_no_notes.merge(notes: ''))
    end
  end

  describe "after a game is created" do
    let (:item) { fake_saved_game }

    before( :each ) do
      items << item
    end

    it "can sign up for that game" do
      expect(table).to receive(:save).with(hash_including(
        gameId: "abc123", 
        seats: [fake_user_info]
      ))
      games.signup('abc123', fake_user_info)
    end

    it "will not sign up for the game if already signed up" do
      expect(client).not_to receive(:save)
      item[:seats] << fake_user_info
      games.signup('abc123', fake_user_info)
    end
  end
end
