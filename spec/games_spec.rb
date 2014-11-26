require 'games'
require 'aws_client'

describe Games do
  let (:client) { double AwsClient::Connection }
  let (:table) { double AwsClient::Table }
  let (:games) { Games.new client }
  let (:items) { [] }

  before( :each ) do
    allow(FileUtils).to receive(:move)
    allow(SecureRandom).to receive(:uuid) { "abc123" }
    allow(client).to receive(:table) { table }
    allow(table).to receive(:all) { items }
  end

  it "can list the existing games" do
    expect(games.all).to be items
  end

  it "can list current games" do
    cutoff_time = (Time.now.to_f * 1000).to_i - (24 * 60 * 59 * 1000)
    old_game = {datetime: 0}
    new_game = {datetime: cutoff_time}
    items.concat([old_game, new_game])
    expect(games.current).to eq [new_game]
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

    it "can find an individual game" do
      expect(games.find(fake_saved_game[:gameId])).to eq fake_saved_game
    end

    it "can find the games for an individual player" do
      my_games = games.for_user(fake_user_info)
      expect(my_games[:playing]).to eq []
      expect(my_games[:running]).to eq [item]
    end

    it "can sign up for that game" do
      expect(table).to receive(:save).with(hash_including(
        gameId: "abc123", 
        seats: [fake_user_info]
      ))
      expect(games.signup('abc123', fake_user_info)).to be true
    end

    it "will not sign up for the game if already signed up" do
      expect(client).not_to receive(:save)
      item[:seats] << fake_user_info
      expect(games.signup('abc123', fake_user_info)).to be false
    end

    describe "when saving changes to a game" do
      it "validates the GM id" do
        expect do 
          games.update('wrong id', {gameId: 'abc123'})
        end.to raise_error "Unauthorized"
      end

      it "validates the game id" do
        expect do 
          games.update(fake_user_info[:id], {gameId: 'zzz'})
        end.to raise_error "Unknown Game"
      end

      it "saves the game" do
        game_info = {
          gameId: 'abc123',
          title: 'new title',
          chronicle: {scenarioId: 'PZ10'}
        }
        expect(table).to receive(:save).with(hash_including(game_info))
        games.update(fake_user_info[:id], game_info)
      end
    end
  end
end
