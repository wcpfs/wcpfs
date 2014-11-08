require 'eventmachine' 
require 'mailfactory' 
require 'nokogiri'

class MailClient
  def send_new_game(game, users)
    body = create_body(game)
    send_mail_to('benrady@gmail.com', game['title'], body)
  end

  def create_body(game_info)
    date = game_info["date"]
    body_node = Nokogiri::HTML::DocumentFragment.parse File.read('mail_templates/new_game.html')
                              
    game_info.each do |k, v|
      content_node = body_node.at_css('.' + k)
      content_node.content = v if content_node
    end
    body_node.at_css('.gm_profile_pic')['src'] = game_info['gm_pic']
    body_node.to_html
  end

  private

  def send_mail_to(to_addr, title, body)
    # Untested
    mail = MailFactory.new
    mail.to = to_addr
    mail.from = 'scheduler@windycitypathfinder.com'
    mail.subject = title
    mail.html = body

    email = EM::P::SmtpClient.send(
      :to=>mail.to,
      :content=>"#{mail.to_s}\r\n.\r\n",
      :header=> {"Subject" => mail.subject},
      :domain=>"windycitypathfinder.com",
      :host=>'mail.windycitypathfinder.com',
      :port=>587,   
      :auth => {
        :type=>:plain, 
        :username=>"scheduler@windycitypathfinder.com", 
        :password=> ENV['EMAIL_PASSWORD']
      },
      :verbose => true
    )
    email.callback{
      puts 'Email sent!'
    }
    email.errback{ |e|
      puts 'Email failed!'
    }
  end

end
