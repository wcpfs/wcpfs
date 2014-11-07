require 'users'
require 'aws-sdk'

describe Users do
  let (:items) { [] }
  let (:client) { double Aws::DynamoDB::Client }
  let (:users) { Users.new client, 'users-table' }
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
    allow(client).to receive :put_item
    resp = spy('resp')
    allow(resp).to receive(:items) { items }
    allow(client).to receive(:scan) { resp }
  end

  it "can ensure a user is in the database" do
    expect(client).to receive(:put_item).with(hash_including(item: {
      email: 'benrady@gmail.com',
      name: 'Ben Rady',
      pic: pic_url,
      id: "google-" + profile["id"]
    }))
    users.ensure(profile)
  end
  
end
