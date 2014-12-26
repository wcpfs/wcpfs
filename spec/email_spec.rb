require 'email'

class Field
  def initialize(val)
    @value = val
  end

  def value
    @value
  end
end

describe "Email" do
  let (:new_mail) { double "new_mail" }
  let (:header) { double "header" }
  let (:field) { Field.new "reply-to-id" }
  let (:id_field) { Field.new "email-id"}
  let (:from_field) { Field.new "Alex Disney <alexdisney@gmail.com>"}
  let (:message) { double "message" }
  let (:body) { double "body" }
  let (:email) { Email.new(new_mail) }

  before( :each ) do
    allow(new_mail).to receive(:header) { header }
    allow(new_mail).to receive(:parts) { [message, message] }
    allow(header).to receive(:[]).with("In-Reply-To") { field }
    allow(header).to receive(:[]).with("Message-ID") { id_field }
    allow(header).to receive(:[]).with("From") { from_field }
    allow(message).to receive(:body) { body }
    allow(body).to receive(:decoded) { "The email message" }
  end

  it "can get the message" do
    expect(email.message).to eq "The email message"
  end

  it "can get the reply to id" do
    expect(email.in_reply_to).to eq "reply-to-id"
  end

  it "can get the email id" do
    expect(email.email_id).to eq "email-id"
  end

  it "can get the sender name" do
    expect(email.sender).to eq "Alex Disney"
  end
  
  it "marks the sender as Unknown when blank" do
    allow(header).to receive(:[]).with("From") { Field.new "" }
    expect(email.sender).to eq "Unknown"
  end

  it "can remove email addresses in the sender" do
    allow(header).to receive(:[]).with("From") { Field.new "alexdisney@gmail.com" }
    expect(email.sender).to eq "Unknown"
  end
end
