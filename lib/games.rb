require 'docsplit'

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
    if game and not joined?(game, player_info) 
      game[:seats] << player_info
      @table.save(game)
    end
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

  def write_pdf(user_id, game_id, pdf_file, filename)
    game = find game_id
    if game.nil? or game[:gm_id] != user_id
      raise "Unauthorized"
    end
    out_dir = "game_assets/#{game_id}"
    FileUtils.mkdir_p(out_dir)
    extract_assets(out_dir, pdf_file.read)
    game[:chronicle] = "/game/#{game_id}/chronicle.png"
  end

  private

  def extract_assets(output_dir, pdf_data)
    filename = "#{output_dir}/scenario.pdf"
    File.open(filename, 'w') do |f|
      f.write pdf_data
    end
    length = Docsplit.extract_length(filename)
    Docsplit.extract_images(filename, density: 150, format: :png, pages: [length], output: output_dir)
  end

  def joined? (game, player_info)
    game[:seats].any? do |seat|
      seat[:email] == player_info[:email]
    end
  end
end
