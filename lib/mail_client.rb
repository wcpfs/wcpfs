require 'eventmachine' 
require 'mailfactory' 
require 'nokogiri'
require 'mail'

class MailClient
  def initialize
    @base_url = 'http://www.windycitypathfinder.com'
    Mail.defaults do
      retriever_method :pop3, :address => "mail.windycitypathfinder.com",
        :port       => 995,
        :user_name  => 'scheduler@windycitypathfinder.com',
        :password   => ENV['EMAIL_PASSWORD'],
        :enable_ssl => true
    end
  end

  def send_new_game(game, users)
    body = create_body(game)
    users.each do |user|
      send_mail_to(user[:email], "[WCPFS] " + game[:title], body)
    end
  end

  def send_join_game(game, joiner)
    send_mail_to(joiner[:email], "[WCPFS] You joined " + game[:title], create_body(game))
  end

  def create_body(game_info)
    date = game_info[:datetime]
    body_node = Nokogiri::HTML::DocumentFragment.parse File.read('mail_templates/new_game.html')
                              
    game_info.each do |k, v|
      content_node = body_node.at_css('.' + k.to_s)
      content_node.content = v if content_node
    end

    body_node.at_css('.date').content = Time.at(date / 1000).strftime("%A, %B %-d")
    body_node.at_css('.gm_profile_pic')['src'] = game_info[:gm_pic]
    body_node.at_css('.join-link')['href'] = @base_url + '/user/joinGame?gameId=' + game_info[:gameId]

    body_node.to_html
  end

  private

  def send_mail_to(to_addr, title, body)
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
      puts "Email sent to #{to_addr}"
    }
    email.errback{ |e|
      puts "Email failed to send to #{to_addr}"
      puts e
    }
    mail.get_header "Message-ID"
  end

end
