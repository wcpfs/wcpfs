require 'mail_client'
require 'nokogiri'

describe MailClient do
  let (:client) { MailClient.new }
  let (:game) {{
    "gameId" => 'abc123', 
    "seats" => [],
    "gm_name" => "Ben Rady",
    "gm_pic" => "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50",
    "gm_id" => 123456,
    "date" => "Sunday June 3rd",
    "datetime" => 123456789000,
    "title" => "City of Golden Death!",
    "notes" => "Notes notes notes!"
  }}

  describe "when creating the email body" do
    let (:body) { Nokogiri::HTML(client.create_body(game)) }

    it "fills in the title" do
      expect(body.css('.title').text).to eq("City of Golden Death!")
    end

    it "fills in the date" do
      expect(body.css('.date').text).to eq("Sunday June 3rd")
    end

    it "fills in the GM pic" do
      expect(body.css('.gm_profile_pic').attr('src')).to match(/\.jpg/)
    end
  end
end
