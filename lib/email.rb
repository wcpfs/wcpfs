class Email
  def initialize(new_mail)
    @message = new_mail.parts[0].body.decoded
    @in_reply_to = new_mail.header["In-Reply-To"].value
    @email_id = new_mail.header["Message-ID"].value
  end

  attr_reader :message
  attr_reader :in_reply_to
  attr_reader :email_id
end
