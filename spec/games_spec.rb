require 'games'

describe Games do
  let (:client) { double 'client' }
  let (:games) { Games.new }

  before( :each ) do
    allow(Aws::DynamoDB::Client).to receive(:new) { client }
  end

  it "can create a new game" do
    allow(client).to receive :put_item
    expect(SecureRandom).to receive(:uuid) { "abc123" }
    item = { GM: "benrady@gmail.com", date: "2014-11-05" }
    games.create(item)
    expect(client).to have_received(:put_item).with(hash_including({
      table_name: "wcpfs-games-test", 
      item: item.merge(gameId: "abc123")
    }))
  end

  it "can list the existing games" do
    resp = spy('resp')
    items = [:items]
    expect(resp).to receive(:items) { items }
    allow(client).to receive(:scan) { resp }
    expect(games.all).to eq items
  end

  it "removes domain names from emails"

  it "ensures the datetime field is an integer"

  it "caches the game list" do
    allow(client).to receive(:scan) { spy ('resp') }
    games.all
    expect(client).to_not receive(:scan)
    games.all
  end

  it "updating the games invalidates the cache" do
    allow(client).to receive(:scan) { spy ('resp') }
    allow(client).to receive(:put_item) 
    games.all
    games.create({})

    expect(client).to receive(:scan) { spy('resp') }
    games.all
  end
end
