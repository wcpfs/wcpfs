require 'email'

describe "Email" do
  let (:new_mail) { double "new_mail" }
  let (:header) { double "header" }
  let (:field) { double "field" }
  let (:id_field) { double "id_field" }
  let (:message) { double "message" }
  let (:body) { double "body" }
  let (:email) { Email.new(new_mail) }

  before( :each ) do
    allow(new_mail).to receive(:header) { header }
    allow(new_mail).to receive(:parts) { [message, message] }
    allow(header).to receive(:[]).with("In-Reply-To") { field }
    allow(header).to receive(:[]).with("Message-ID") { id_field }
    allow(field).to receive(:value) { "reply-to-id" }
    allow(id_field).to receive(:value) { "email-id" }
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
end
