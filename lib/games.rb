require 'aws-sdk'

class Games
  def initialize
    @client = Aws::DynamoDB::Client.new( :region => 'us-east-1' )
    @table_name = 'wcpfs-games-test'
  end

  def create game_info
    @games = nil
    item = {
      gameId: SecureRandom.uuid,
      table_name: "wcpfs-games-test",
      item: game_info
    }
    @client.put_item(item)
    item
  end

  def all
    if @games.nil?
      @games = @client.scan(table_name: "wcpfs-games-test").items
    end
    return @games
  end
end
