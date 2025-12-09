require "rails_helper"

RSpec.describe Message, type: :model do
  let(:sender)    { User.create!(email: "sender@example.com",    password: "password") }
  let(:recipient) { User.create!(email: "recipient@example.com", password: "password") }

  it "is valid with a sender, recipient, and body" do
    message = described_class.new(sender: sender, recipient: recipient, body: "Hello there")
    expect(message).to be_valid
  end

  it "requires a body" do
    message = described_class.new(sender: sender, recipient: recipient, body: nil)
    expect(message).not_to be_valid
    expect(message.errors[:body]).to include("can't be blank")
  end

  it "can be marked as read" do
    message = described_class.create!(sender: sender, recipient: recipient, body: "Hello", read_at: nil)
    expect { message.mark_read! }.to change(message, :read_at).from(nil)
  end

  it "scopes unread messages" do
    unread = described_class.create!(sender: sender, recipient: recipient, body: "Unread", read_at: nil)
    described_class.create!(sender: sender, recipient: recipient, body: "Read", read_at: Time.current)

    expect(described_class.unread).to contain_exactly(unread)
  end
end
