require 'aws_client'

describe AwsClient do
  let (:client) { double Aws::DynamoDB::Client }

  before( :each ) do
    allow(Aws::DynamoDB::Client).to receive(:new) {client}
  end

  it "can create a connection" do
    opts = { 
      :region => 'us-east-1',
      access_key_id: 'abc',
      secret_access_key: '123'
    }

    expect(Aws::DynamoDB::Client).to receive(:new).with(opts)
    AwsClient.connect(opts)
  end

  describe 'using a table' do
    let (:items) { [] }
    let (:conn) { AwsClient.connect({}, 'test')}
    let (:response) { spy 'resp' }
    let (:table) { conn.table('mytable') }

    before( :each ) do
      allow(client).to receive(:scan) { response }
      allow(response).to receive(:items) { items }
    end

    it "can get all the entities" do
      items.concat [{}, {}]
      expect(table.all.size).to eq 2
    end

    it "transforms keys into symbols" do
      items << {"foo" => "bar", "biz" => [{"baz" => "bop"}]}
      expect(table.all.first).to eq({
        :foo => 'bar',
        :biz => [{:baz => "bop"}]
      })
    end

    it "converts BigDecimals to numbers" do
      items << { big: BigDecimal.new(1234567890000) }
      expect(table.all.first).to eq({
        :big => 1234567890000
      })
    end

    it "keeps a local cache" do
      expect(client).to receive(:scan).once
      2.times {table.all}
    end

    it "can save an item" do
      expect(client).to receive(:put_item).with({
        table_name: 'mytable-test',
        item: {}
      })
      table.save({})
    end

    it "can update an item" do
      expect(client).to receive(:update_item).with({
        table_name: 'mytable-test',
        key: {
          hash_key_element: {s: 'myGameId'}
        },
        attribute_updates: {
          "email_ids" => {
            value: {ss: ['new-mail-id']},
            action: "ADD"}
        }})
      table.update_add('myGameId', 'email_ids', 'new-mail-id')
    end
  end
end
