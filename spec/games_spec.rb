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
    let (:saved_game) {fake_new_game_no_notes.merge(gameId: "abc123", seats: [], email_ids: [])}

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
      expect(table).not_to receive(:save)
      item[:seats] << fake_user_info
      expect(games.signup('abc123', fake_user_info)).to be false
    end

    it "can add email thread ids" do
      expect(table).to receive(:save).with(item)
      item[:email_ids] = ['myFirstEmailId']
      games.add_discussion_thread_id('abc123', 'myEmailId')
    end

    describe 'when attaching a scenario PDF' do
      let (:f) { double File }
      let (:data) { StringIO.new 'file data' }

      before( :each ) do
        allow(FileUtils).to receive('mkdir_p')
        allow(table).to receive(:save)
        allow(Docsplit).to receive(:extract_images)
        allow(Docsplit).to receive(:extract_length) { 10 }
        allow(File).to receive(:open).and_yield f
        allow(f).to receive(:write)
      end

      it "writes the file to disk" do
        expect(FileUtils).to receive(:mkdir_p).with('game_assets/abc123')
        expect(f).to receive(:write).with('file data')
        games.write_pdf(fake_user_info[:id], 'abc123', data, 'file name') 
      end

      it "extracts the chronicle sheet" do
        expect(Docsplit).to receive(:extract_images).with('game_assets/abc123/scenario.pdf', {
          size: '628x816',
          format: :png,
          pages: [10],
          output: 'game_assets/abc123'
        })
        expect(FileUtils).to receive(:move).with('game_assets/abc123/scenario_10.png', 'game_assets/abc123/chronicle.png')
        games.write_pdf(fake_user_info[:id], 'abc123', data, 'file name') 
      end

      it "raises an error if the user is not the GM" do
        expect do 
          games.write_pdf('wrong id', nil, nil, nil)
        end.to raise_error "Unauthorized"
      end

      it "updates the game assets" do
        expect(table).to receive(:save).with(games.all.first)
        games.write_pdf(fake_user_info[:id], 'abc123', data, 'file name')
        expect(games.all.first[:chronicle][:sheetUrl]).to eq '/game/abc123/chronicle.png'
      end
    end
  end
end
