require 'games'
require 'aws_client'
require 'mail_client'

describe Games do
  let (:client) { double AwsClient::Connection }
  let (:mail_client) { double MailClient }
  let (:table) { double AwsClient::Table }
  let (:games) { Games.new client, mail_client }
  let (:items) { [] }

  before( :each ) do
    allow(FileUtils).to receive(:move)
    allow(SecureRandom).to receive(:uuid) { "abc123" }
    allow(mail_client).to receive(:send_chronicle)
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

  it "doesn't list private games" do
    cutoff_time = (Time.now.to_f * 1000).to_i - (24 * 60 * 59 * 1000)
    private_game = {private: true, datetime: cutoff_time}
    public_game = {private: false, datetime: cutoff_time}
    items.concat([private_game, public_game])
    expect(games.current).to eq [public_game]
  end

  describe "when creating games" do
    let (:saved_game) {fake_new_game_no_notes.merge(id: "abc123", seats: [], email_ids: [])}

    before( :each ) do
      allow(table).to receive(:save)
    end

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
      expect(games.find(fake_saved_game[:id])).to eq fake_saved_game
    end

    it "can cancel the game" do
      expect(table).to receive(:delete).with(fake_saved_game[:id])
      games.cancel(fake_saved_game[:gm_id], fake_saved_game[:id])
    end

    it "can find the games for an individual player" do
      my_games = games.for_user(fake_user_info)
      expect(my_games[:playing]).to eq []
      expect(my_games[:running]).to eq [item]
    end

    it "can sign up for that game" do
      expect(table).to receive(:save).with(hash_including(
        id: "abc123", 
        seats: [fake_user_info]
      ))
      expect(games.signup('abc123', fake_user_info)).to be true
    end

    it "can leave that game" do
      allow(table).to receive(:save)
      games.signup('abc123', fake_user_info)
      expect(table).to receive(:save).with(hash_including(
        id: "abc123", 
        seats: []
      ))
      games.leave('abc123', fake_user_info)
    end

    it "will not sign up for the game if already signed up" do
      expect(table).not_to receive(:save)
      item[:seats] << fake_user_info
      expect(games.signup('abc123', fake_user_info)).to be false
    end

    it "can send a chronicle sheet to all the players" do
      expect(mail_client).to receive(:send_chronicle).with("rene@gmail.com", "City of Golden Death!", "ABCPNG")
      game = items.first
      game[:seats] << {:email => 'rene@gmail.com'}
      games.send_chronicle(fake_user_info, 'abc123', "ABCPNG")
    end

    describe "discussion" do
      it "can add email thread ids" do
        expect(table).to receive(:save).with(item)
        item[:email_ids] = ['myFirstEmailId']
        games.add_discussion_thread_id('abc123', 'myEmailId')
      end

      it "can find a game by email id" do
        item[:email_ids] = ["myEmailId", "otherEmailId"]
        expect(games.find_by_discussion "myEmailId").to eq item
      end

      describe "on discussion" do
        let (:email) { double "email" }

        before( :each ) do
          item[:message] = ""
          item[:email_ids] = ["join_email", "reply_to_id"]
          allow(table).to receive(:save)
          allow(games).to receive(:find_by_discussion) { item }
          allow(mail_client).to receive(:send_discussion) { ["new_id"] }
          allow(Email).to receive(:new) { email }
          allow(email).to receive(:message) {"new discussion"}
          allow(email).to receive(:in_reply_to) {"reply_to_id"}
          allow(email).to receive(:sender) {"Alex Disney"}
        end

        it "does nothing if no game found with mail id" do
          allow(games).to receive(:find_by_discussion) { }
          allow(email).to receive(:in_reply_to) {"bad_id"}
          expect(table).to_not receive(:save)
          games.on_discussion(email)
        end

        it "saves the game" do
          expect(table).to receive(:save).with(item)
          games.on_discussion(email)
        end

        let (:message) { double "message" }
        let (:ascii) { double "ascii" }
        it "converts the text to UTF-8" do
          expect(message).to receive(:force_encoding).with("ASCII-8BIT") { ascii }
          expect(ascii).to receive(:encode).with("UTF-8", undef: :replace, replace: '')
          games.encode_message message
        end

        it "updates the game discussion on new message" do
          games.on_discussion(email)
          expect(item[:discussion]).to eq "Alex Disney says:\n\nnew discussion"
        end

        it "appends the new email id" do
          games.on_discussion(email)
          expect(item[:email_ids]).to eq(["join_email", "reply_to_id", "new_id"])
        end

        it "does not append the email id if already there" do
          item[:email_ids] << "new_id"
          games.on_discussion(email)
          expect(item[:email_ids]).to eq(["join_email", "reply_to_id", "new_id"])
        end

        it "sends the discussion email" do
          expect(mail_client).to receive(:send_discussion).with(item)
          games.on_discussion(email)
        end
      end
    end

    it "sends a chronicle sheet to the GM" do
      expect(mail_client).to receive(:send_chronicle).with("benrady@gmail.com", "City of Golden Death!", "ABCPNG")
      games.send_chronicle(fake_user_info, 'abc123', "ABCPNG")
    end

    describe "when saving changes to a game" do
      it "validates the GM id" do
        expect do 
          games.update('wrong id', {id: 'abc123'})
        end.to raise_error "Unauthorized"
      end

      it "validates the game id" do
        expect do 
          games.update(fake_user_info[:id], {id: 'zzz'})
        end.to raise_error "Unknown Game"
      end

      it "saves the game" do
        game_info = {
          id: 'abc123',
          title: 'new title',
          chronicle: {scenarioId: 'PZ10'}
        }
        expect(table).to receive(:save).with(hash_including(game_info))
        games.update(fake_user_info[:id], game_info)
      end
    end
  end
end
