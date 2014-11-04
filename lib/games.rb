require 'aws-sdk'

class Games
  def initialize
    @client = Aws::DynamoDB::Client.new({
      :region => 'us-east-1',
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    })
    @table_name = ENV["GAMES_TABLE_NAME"] || 'wcpfs-games-test'
  end

  def create game_info
    @games = nil
    item = game_info.merge(gameId: SecureRandom.uuid)
    params = {
      table_name: "wcpfs-games-test",
      item: item
    }
    @client.put_item(params)
    item
  end

  def all
    if @games.nil?
      @games = @client.scan(table_name: "wcpfs-games-test").items
    end
    return @games
  end

  def signup game_id, email
  end
end
