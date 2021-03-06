require 'eventmachine' 
require 'mailfactory' 
require 'nokogiri'
require 'mail'
require 'email'

class MailClient
  def initialize(env=nil)
    if env
      @username = "scheduler-#{env}@windycitypathfinder.com"
    else
      @username = 'scheduler@windycitypathfinder.com'
    end
    @base_url = 'http://www.windycitypathfinder.com'
    receive_mail @username
  end

  def receive_mail(username)
    Mail.defaults do
      retriever_method :imap, :address => "mail.windycitypathfinder.com",
        :port              => 993,
        :user_name         => username,
        :password          => ENV['EMAIL_PASSWORD'],
        :enable_ssl        => true,
        :delete_after_find => true
    end
  end

  def check_mail
    received_mail = Mail.find({ delete_after_find: true })
    if received_mail.length > 0
      return received_mail.map { | mail | Email.new(mail) }
    end
  end

  def send_new_game(game, users)
    body = create_body(game)
    users.each do |user|
      send_mail_to(user[:email], "[WCPFS] " + game[:title], body)
    end
  end

  def discussion_title(game_title)
    "[WCPFS] Discussion: " + game_title 
  end

  def send_discussion(game)
    title = discussion_title(game[:title])
    body = create_discussion_body(game)
    sent_ids = game[:seats].map { |seat| send_mail_to(seat[:email], title, body) }
    sent_ids << send_mail_to(game[:gm_email], title, body)
  end

  def send_join_game(game, joiner)
    send_mail_to(joiner[:email], discussion_title(game[:title]), create_discussion_body(game))
  end

  def send_chronicle(email, title, chronicle_sheet_img)
    send_mail_to(email, "[WCPFS] Chronicle Sheet for #{title}", "Thanks for playing!", chronicle_sheet_img)
  end

  def create_discussion_body(game_info)
    body_node = Nokogiri::HTML::DocumentFragment.parse File.read('mail_templates/discussion.html')

    date = game_info[:datetime] 
    body_node.at_css('.date').content = Time.at(date / 1000).strftime("%A, %B %-d")
    body_node.at_css('.title').content = game_info[:title]
    body_node.at_css('.discussion').content = game_info[:discussion] ? game_info[:discussion] : game_info[:notes]

    body_node.to_html
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
    body_node.at_css('.join-link')['href'] = @base_url + '/user/joinGame?id=' + game_info[:id]

    body_node.to_html
  end

  private

  def send_mail_to(to_addr, title, body, attachment=nil)
    mail = MailFactory.new
    mail.to = to_addr
    mail.from = @username
    mail.subject = title
    mail.html = body
    if attachment
      mail.add_attachment_as(StringIO.new(attachment), 'chronicle.png', 'image/png')
    end

    email = EM::P::SmtpClient.send(
      :to=>mail.to,
      :content=>"#{mail.to_s}\r\n.\r\n",
      :header=> {"Subject" => mail.subject},
      :domain=>"windycitypathfinder.com",
      :host=>'mail.windycitypathfinder.com',
      :port=>587,   
      :auth => {
        :type=>:plain, 
        :username=>@username,
        :password=> ENV['EMAIL_PASSWORD']
      },
      :verbose => true
    )
    
    email.callback{
      puts "Email sent to #{to_addr}"
    }
    email.errback{ |e|
      puts "Email failed to send to #{to_addr}"
      puts e.inspect
    }
    mail.get_header("Message-ID").first
  end
end
