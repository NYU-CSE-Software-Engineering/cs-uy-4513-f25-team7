require "rails_helper"

RSpec.describe Notification, type: :model do
  let(:recipient) { User.create!(email: "recipient@example.com", password: "password") }
  let(:actor) { User.create!(email: "actor@example.com", password: "password") }

  it "is valid with required attributes" do
    notification = described_class.new(user: recipient, actor: actor, event_type: "follow_created")
    expect(notification).to be_valid
  end

  it "scopes unread notifications" do
    unread = described_class.create!(user: recipient, actor: actor, event_type: "follow_created", read_at: nil)
    described_class.create!(user: recipient, actor: actor, event_type: "follow_created", read_at: Time.current)

    expect(described_class.unread).to contain_exactly(unread)
  end

  it "marks notifications as read" do
    notification = described_class.create!(user: recipient, actor: actor, event_type: "follow_created", read_at: nil)
    expect { notification.mark_read! }.to change(notification, :read_at).from(nil)
  end
end
