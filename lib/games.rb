require 'aws_entity'

class Games
  include AWSEntity

  def create game_info
    game = game_info.merge('gameId' => SecureRandom.uuid, 'seats' => [])
    game.delete('notes') if game['notes'].nil? or game['notes'].length == 0
    save(game)
  end

  def signup game_id, player_info
    game = all.find {|g| g["gameId"] == game_id}
    if game and not_joined(game, player_info) 
      game["seats"] << player_info
      save(game)
    end
  end

  private

  def not_joined(game, player_info)
    not game["seats"].map{|p| p['email']}.include?(player_info['email'])
  end
end
