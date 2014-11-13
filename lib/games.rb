class Games
  def initialize(aws_connection)
    @table = aws_connection.table('wcpfs-games')
  end

  def create game_info
    game = game_info.merge(gameId: SecureRandom.uuid, seats: [])
    game.delete(:notes) if game[:notes].nil? or game[:notes].length == 0
    @table.save(game)
  end

  def signup game_id, player_info
    game = @table.all.find {|g| g[:gameId] == game_id}
    if game and not_joined(game, player_info) 
      game[:seats] << player_info
      @table.save(game)
    end
  end

  def find game_id
    @table.all.find {|g| g[:gameId] == game_id}
  end

  def all
    @table.all
  end

  private

  def not_joined(game, player_info)
    not game[:seats].any? do |seat|
      seat[:email] == player_info[:email]
    end
  end
end
