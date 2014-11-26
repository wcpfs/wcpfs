require 'docsplit'

class Games
  TWENTY_FOUR_HOURS = 24 * 60 * 60 * 1000
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
    if game and not joined?(game, player_info) 
      game[:seats] << player_info
      @table.save(game)
      return true
    end
    return false
  end

  def find game_id
    @table.all.find {|g| g[:gameId] == game_id}
  end

  def for_user(user_info)
    {
      running: all.select {|g| g[:gm_id] == user_info[:id]},
      playing: all.select {|g| joined?(g, user_info) }
    }
  end

  def all
    @table.all
  end

  def current
    @table.all.select do |game|
      game[:datetime] > now_millis - TWENTY_FOUR_HOURS 
    end
  end

  def update(user_id, game_info)
    game = find game_info[:gameId]
    raise "Unknown Game" if game.nil? 
    raise "Unauthorized" if game[:gm_id] != user_id

    @table.save(game.merge(game_info))
  end

  private

  def joined? (game, player_info)
    game[:seats].any? do |seat|
      seat[:email] == player_info[:email]
    end
  end

  def now_millis
    (Time.now.to_f * 1000).to_i
  end
end
