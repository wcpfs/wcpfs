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

    def normalize item
      JSON.parse(item.to_json, :symbolize_names => true)
    end
  end
end
