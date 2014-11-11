require 'mail_client'
require 'nokogiri'

describe MailClient do
  let (:email) { double 'email' }
  let (:client) { MailClient.new }
  let (:game) {{
    "gameId" => 'abc123', 
    "seats" => [],
    "gm_name" => "Ben Rady",
    "gm_pic" => "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    "gm_id" => 123456,
    "datetime" => 123456789000,
    "title" => "City of Golden Death!",
    "notes" => "Notes notes notes!"
  }}

  before( :each ) do
    allow(email).to receive(:callback)
    allow(email).to receive(:errback)
  end

  it "sends emails to all users" do
    expect(EM::P::SmtpClient).to receive(:send).twice { email }
    client.send_new_game(game, [{"email" => 'benrady@gmail.com'}, {"email" => 'rene@rene.com'}])
  end

  describe "when creating the email body" do
    let (:body) { Nokogiri::HTML(client.create_body(game)) }

    it "fills in the title" do
      expect(body.css('.title').text).to eq("City of Golden Death!")
    end

    it "fills in the date" do
      expect(body.css('.date').text).to eq("Wednesday, January 1")
    end

    it "fills in the GM pic" do
      expect(body.css('.gm_profile_pic').attr('src').text).to match(/\.jpg/)
    end

    it "fills in the join link" do
      expect(body.css('.join-link').attr('href').text).to eq('http://beta.windycitypathfinder.com/user/joinGame?gameId=abc123')
    end
  end
end
