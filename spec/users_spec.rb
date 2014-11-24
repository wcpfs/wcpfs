require 'users'
require 'aws_client'

describe Users do
  let (:client) { double AwsClient::Connection }
  let (:table) { double AwsClient::Table }
  let (:items) { [] }
  let (:users) { Users.new client }
  let (:pic_url) { "https://lh5.googleusercontent.com/-Pv6s3xoudeE/AAAAAAAAAAI/AAAAAAAAAAA/wa9VTBF_kws/photo.jpg?sz=50" }
  let(:profile) {{
    "kind" => "plus#person",
    "etag" => "\"MoxPKeu0NQD8g5Gtts3ebh50504/2fOz_vnkSPUUKdUqR8k0qy6axpQ\"",
    "occupation" => "Senior Software Developer",
    "gender" => "male",
    "emails" => [{"value" => "benrady@gmail.com","type" => "account"}],
    "urls" => [],
    "objectType" => "person",
    "id" => "113769764833315172586",
    "displayName" => "Ben Rady",
    "name" => {"familyName" => "Rady","givenName" => "Ben"},
    "aboutMe" => "...",
    "url" => "https://plus.google.com/+BenRady",
    "image" => {
      "url" => pic_url,
      "isDefault" => false},
    "isPlusUser" => true,
    "language" => "en",
    "verified" => false,
    "cover" => {}
  }}

  before( :each ) do
    allow(client).to receive(:table) { table }
    allow(table).to receive(:all) { items }
  end

  it "can ensure a user is in the database" do
    expect(table).to receive(:save).with(fake_user_info)
    users.ensure(profile)
  end
  
  describe "after a user is added" do
    before( :each ) do
      items << fake_user_info 
    end

    it "can subscribe a user to new game updates" do
      expect(table).to receive(:save).with(fake_user_info.merge(subscribed: true))
      users.subscribe(fake_user_info[:id])
    end

    it "can get the list of subscribed users" do
      items[0][:subscribed] = true
      expect(users.subscriptions.first).to include email: 'benrady@gmail.com'
    end

    it "can update the fields for a user" do
      expect(table).to receive(:save).with(hash_including(pfsNumber: 12345))
      new_info = {:pfsNumber => 12345,
                  :signatureUrl => 'http://example.org',
                  :initialsUrl => 'http://example.org'}
      users.update(fake_user_info[:id], new_info)
      expect(users.find(fake_user_info[:id])).to include pfsNumber: 12345
    end

    it "Throws error when new_info contains unknown fields" do
      new_info = {fakeField: 'fakeField'}
      expect {
        users.update(fake_user_info[:id], new_info)
      }.to raise_error.with_message "Bad User Field(s) [:fakeField]"
    end
  end
end
