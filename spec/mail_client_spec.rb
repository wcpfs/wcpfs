require 'mail_client'
require 'mail'
require 'nokogiri'

describe MailClient do
  let (:email) { double 'email' }
  let (:client) { MailClient.new }
  let (:game) { fake_saved_game }

  before( :each ) do
    allow(email).to receive(:callback)
    allow(email).to receive(:errback)
  end

  describe "receiving mail" do
    let (:new_mail) { double "new_mail" }

    before( :each ) do
      allow(Mail).to receive(:defaults)
      allow(Mail).to receive(:find) { [ new_mail ] }
      allow(EM).to receive(:next_tick).and_yield
      allow(EM).to receive(:add_periodic_timer).and_yield
      allow(Email).to receive(:new)
    end

    it "initializes imap connection" do
      expect(Mail).to receive(:defaults).and_call_original
      expect(Mail::IMAP).to receive(:new).
        with({:address           => "mail.windycitypathfinder.com",
              :port              => 993,
              :user_name         => 'scheduler@windycitypathfinder.com',
              :password          => ENV['EMAIL_PASSWORD'],
              :enable_ssl        => true,
              :delete_after_find => true})
      MailClient.new
    end

    it "checks for mail" do
      expect(Mail).to receive(:find)
      client.check_mail
    end

    it "returns nothing if no mail" do
      allow(Mail).to receive(:find) { [] }
      expect(client.check_mail).to be nil
    end

    it "can handle more than one email at a time" do
      allow(Mail).to receive(:find) { [ email, email, email ] }
      expect(client.check_mail.length).to be 3
    end

    it "deletes emails after handling them" do
      expect(Mail).to receive(:find).with({ delete_after_find: true })
      client.check_mail
    end
  end

  describe "on player join" do
    it "can send an email to one player" do
      expect(EM::P::SmtpClient).to receive(:send) { email }
      client.send_join_game(game, fake_user_info)
    end
  end

  describe "discussion message" do
    let (:game) { fake_saved_game_with_discussion }
    let (:body) { Nokogiri::HTML(client.create_discussion_body(game)) }

    it "sends to players and GM" do
      game[:seats] = [{email: "rene@rene.com", name:"Rene Duquesnoy"}, {email:"adisney@gmail.com", name:"Alex Disney"}]
      expect(EM::P::SmtpClient).to receive(:send).once.ordered.with(hash_including(to: ["benrady@gmail.com"])) { email }
      expect(EM::P::SmtpClient).to receive(:send).once.ordered.with(hash_including(to: ["rene@rene.com"])) { email }
      expect(EM::P::SmtpClient).to receive(:send).once.ordered.with(hash_including(to: ["adisney@gmail.com"])) { email }
      client.send_discussion(game)
    end

    it "populates the game title" do
      expect(body.css('.title').text).to eq("City of Golden Death!")
    end
    
    it "populates the date" do
      expect(body.css('.date').text).to eq("Friday, February 13")
    end

    it "populates the body with discussion" do
      expect(body.css('.discussion').text).to eq("Part of the discussion.\n    > A quote from previous\n    > conversations")
    end
  end

  describe "on game create" do
    it "sends emails to all users" do
      expect(EM::P::SmtpClient).to receive(:send).twice { email }
      client.send_new_game(game, [fake_user_info, fake_user_info_2])
    end

    describe "when creating the email body" do
      let (:body) { Nokogiri::HTML(client.create_body(game)) }

      it "fills in the title" do
        expect(body.css('.title').text).to eq("City of Golden Death!")
      end

      it "fills in the date" do
        expect(body.css('.date').text).to eq("Friday, February 13")
      end

      it "fills in the GM pic" do
        expect(body.css('.gm_profile_pic').attr('src').text).to match(/\.jpg/)
      end

      it "fills in the join link" do
        expect(body.css('.join-link').attr('href').text).to eq('http://www.windycitypathfinder.com/user/joinGame?gameId=abc123')
      end
    end
  end
end
