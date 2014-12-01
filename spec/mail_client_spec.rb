require 'mail_client'
require 'mail'
require 'nokogiri'

describe MailClient do
  let (:email) { double 'email' }
  let (:client) { MailClient.new({}) }
  let (:game) { fake_saved_game }

  before( :each ) do
    allow(email).to receive(:callback)
    allow(email).to receive(:errback)
  end

  describe "receiving mail" do
    let (:new_mail) { double "new_mail" }
    let (:header) { double "header" }
    let (:message) { double "message" }
    let (:body) { double "body" }

    before( :each ) do
      allow(Mail).to receive(:defaults)
      allow(EM).to receive(:next_tick).and_yield
      allow(EM).to receive(:add_periodic_timer).and_yield
      allow(Mail).to receive(:last) { new_mail }
      allow(new_mail).to receive(:header) { header }
      allow(new_mail).to receive(:parts) { [message, message] }
      allow(header).to receive(:[])
      allow(message).to receive(:body) { body }
      allow(body).to receive(:decoded)
    end

    it "initializes imap connection" do
      expect(Mail).to receive(:defaults).and_call_original
      expect(Mail::IMAP).to receive(:new).
        with({:address => "mail.windycitypathfinder.com",
              :port       => 993,
              :user_name  => 'scheduler@windycitypathfinder.com',
              :password   => ENV['EMAIL_PASSWORD'],
              :enable_ssl => true})
      MailClient.new({})
    end

    it "checks for mail" do
      expect(Mail).to receive(:last)
      client.check_mail
    end

    it "returns nothing if no email" do
      allow(Mail).to receive(:last) { }
      expect(client.check_mail).to be nil
    end

    it "can get mail details" do
      allow(header).to receive(:[]).with("In-Reply-To") { "mailId" }
      allow(body).to receive(:decoded) { "decoded body" }
      received = client.check_mail
      expect(received[:discussion]).to eq "decoded body"
      expect(received[:in_reply_to]).to eq "mailId"
    end
  end

  describe "on player join" do
    it "can send an email to one player" do
      expect(EM::P::SmtpClient).to receive(:send) { email }
      client.send_join_game(game, fake_user_info)
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
