require 'mail_client'
require 'nokogiri'

describe MailClient do
  let (:email) { double 'email' }
  let (:client) { MailClient.new }
  let (:game) { fake_saved_game }

  before( :each ) do
    allow(email).to receive(:callback)
    allow(email).to receive(:errback)
  end

  describe "on player join" do
    it "sends an email to the joining player" do
      expect(EM::P::SmtpClient).to receive(:send) { email }
      client.send_join_game(game, [fake_user_info])
    end

    xit "adds the WCPFS prefix to the title" do
      let (:mail) { double "mail" }
      MailFactory.stub(:new).and_return(mail)
      client.send_join_game(game, [fake_user_info])
      expect(mail.subject).to eq "[WCPFS] Midnight Marauder"
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
