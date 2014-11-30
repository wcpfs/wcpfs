require 'aws-sdk'
require 'bigdecimal'
require 'json'

class BigDecimal
  # Hack to get BigDecimal to serialize properly
  def to_json(options = nil)
    self.to_i.to_s
  end
end

module AwsClient
  def self.connect(opts, env=nil)
    Connection.new(opts, env)
  end

  class Connection
    def initialize(opts, env)
      @suffix = ''
      @suffix = '-' + env if env
      @aws_client = Aws::DynamoDB::Client.new(opts)
    end

    def table(prefix)
      Table.new(@aws_client, prefix + @suffix)
    end
  end

  class Table
    def initialize(aws_client, table_name)
      @client = aws_client
      @table_name = table_name
    end

    def all
      if @cache.nil?
        items = @client.scan(table_name: @table_name).items
        @cache = items.map {|item| normalize item }
      end
      return @cache
    end

    def save(item)
      params = {
        table_name: @table_name,
        item: item
      }
      @client.put_item(params)
      @cache = nil
      item
    end

    def update_add(key, item, value)
      params = {
        table_name: @table_name,
        key: {
          hash_key_element: {s: key}
        },
        attribute_updates: {
          "#{item}" => {
            value: {ss: [value]},
            action: "ADD"}
        }}
      @client.update_item(params)
      #puts @client.scan({:table_name => @table_name}).data
      #puts @client.describe_table({:table_name => @table_name}).data
      #puts @client.get_item(
      #  {:table_name=>"wcpfs-games-test", 
      #   :key=>{:hash_key_element => { :s => "8b91a3cc-8669-44ae-bf40-0dad6e11d373"}}})
      @cache = nil
    end

    def normalize item
      JSON.parse(item.to_json, :symbolize_names => true)
    end
  end
end
