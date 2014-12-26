class Email
  def initialize(new_mail)
    @message = new_mail.parts[0].body.decoded
    @in_reply_to = new_mail.header["In-Reply-To"].value
    @email_id = new_mail.header["Message-ID"].value
    @sender = remove_email_address new_mail.header["From"].value
  end

  def remove_email_address sender_header
    name = sender_header.gsub(/<.*>/, "").strip
    name = name.gsub(/.*@.*\.(com|edu|net|org)/, "").strip

    if (name.empty?)
      return "Unknown"
    else
      return name
    end
  end

  attr_reader :message
  attr_reader :in_reply_to
  attr_reader :email_id
  attr_reader :sender
end
