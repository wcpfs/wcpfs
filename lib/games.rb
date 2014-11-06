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
    game = game_info.merge(gameId: SecureRandom.uuid, seats: [])
    game.delete(:notes) if game[:notes].nil? or game[:notes].length == 0
    save(game)
  end

  def all
    if @games.nil?
      @games = @client.scan(table_name: @table_name).items
    end
    return @games
  end

  def signup game_id, player_info
    game = all.find {|g| g["gameId"] == game_id}
    if game
      game["seats"] << player_info
      save(game)
    end
  end

  private

  def save(game)
    params = {
      table_name: @table_name,
      item: game
    }
    @client.put_item(params)
    @games = nil
    game
  end
end
