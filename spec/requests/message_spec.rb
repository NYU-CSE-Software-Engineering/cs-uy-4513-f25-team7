require "rails_helper"

RSpec.describe "Messages", type: :request do
  def sign_in(user)
    post user_session_path, params: { email: user.email, password: "password" }
  end

  let(:sender)    { User.create!(email: "me@example.com",      password: "password") }
  let(:recipient) { User.create!(email: "misty@example.com",   password: "password") }

  describe "GET /messages" do
    it "requires authentication" do
      get messages_path
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Please sign in to continue")
    end

    it "shows only the current user's inbox" do
      message_for_sender   = Message.create!(sender: recipient, recipient: sender,    body: "Hi sender")
      message_for_recipient = Message.create!(sender: sender,    recipient: recipient, body: "Hi recipient")

      sign_in(recipient)
      get messages_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hi recipient")
      expect(response.body).not_to include("Hi sender")
    end
  end

  describe "POST /messages" do
    it "creates a messages for the recipient when signed in" do
      sign_in(sender)

      expect {
        post messages_path, params: {
          message: {
            recipient_id: recipient.id,
            subject: "Hello",
            body: "Battle?"
          }
        }
      }.to change(Message, :count).by(1)

      expect(response).to redirect_to(message_path(Message.last))
      expect(flash[:notice]).to eq("Message sent.")
      expect(Message.last.sender).to eq(sender)
      expect(Message.last.recipient).to eq(recipient)
    end

    it "rejects a profane body and re-renders the form" do
      sign_in(sender)

      expect {
        post messages_path, params: {
          message: {
            recipient_id: recipient.id,
            subject: "Hello",
            body: "This is darn rude"
          }
        }
      }.not_to change(Message, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("contains inappropriate language")
    end

    it "does not allow sending messages when signed out" do
      expect {
        post messages_path, params: {
          message: {
            recipient_id: recipient.id,
            subject: "Hello",
            body: "Battle?"
          }
        }
      }.not_to change(Message, :count)

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Please sign in to continue")
    end
  end

  describe "GET /messages/new" do
    it "prefills the recipient when provided" do
      sign_in(sender)

      get new_message_path(recipient_id: recipient.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(recipient.display_name)
      expect(response.body).to include(%Q[value="#{recipient.id}"])
    end
  end

  describe "GET /messages/:id" do
    let!(:message) { Message.create!(sender: sender, recipient: recipient, body: "Hello") }

    it "requires authentication" do
      get message_path(message)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Please sign in to continue")
    end

    it "marks the message as read when the recipient views it" do
      sign_in(recipient)
      expect {
        get message_path(message)
      }.to change { message.reload.read_at }.from(nil)

      expect(response).to have_http_status(:ok)
    end

    it "prevents other users from viewing the message" do
      other_user = User.create!(email: "other@example.com", password: "password")
      sign_in(other_user)

      get message_path(message)

      expect(response).to redirect_to(messages_path)
      expect(flash[:alert]).to eq("Not authorized")
    end
  end
end
