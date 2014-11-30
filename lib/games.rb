require 'docsplit'

class Games
  TWENTY_FOUR_HOURS = 24 * 60 * 60 * 1000
  def initialize(aws_connection)
    @table = aws_connection.table('wcpfs-games')
  end

  def create game_info
    game = game_info.merge(gameId: SecureRandom.uuid, seats: [], email_ids: [])
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

  def add_discussion_thread_id game_id, email_id
    game = find game_id
    if game
      game[:email_ids] << email_id
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

  def current
    @table.all.select do |game|
      game[:datetime] > now_millis - TWENTY_FOUR_HOURS 
    end
  end

  def write_pdf(user_id, game_id, pdf_file, filename)
    game = find game_id
    if game.nil? or game[:gm_id] != user_id
      raise "Unauthorized"
    end
    out_dir = "game_assets/#{game_id}"
    FileUtils.mkdir_p(out_dir)
    extract_assets(out_dir, pdf_file.read)
    game[:chronicle] = {
      :sheetUrl => "/game/#{game_id}/chronicle.png"
    }
    @table.save(game)
  end

  private

  def extract_assets(output_dir, pdf_data)
    filename = "#{output_dir}/scenario.pdf"
    File.open(filename, 'w') do |f|
      f.write pdf_data
    end
    length = Docsplit.extract_length(filename)
    Docsplit.extract_images(filename, size: '628x816', format: :png, pages: [length], output: output_dir)
    FileUtils.move( "#{output_dir}/scenario_#{length}.png", "#{output_dir}/chronicle.png")
  end

  def joined? (game, player_info)
    game[:seats].any? do |seat|
      seat[:email] == player_info[:email]
    end
  end

  def now_millis
    (Time.now.to_f * 1000).to_i
  end
end
