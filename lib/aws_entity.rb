module AWSEntity
  def initialize(aws_client, table_name)
    @client = aws_client
    @table_name = table_name
  end

  def all
    if @cache.nil?
      @cache = @client.scan(table_name: @table_name).items
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
end
