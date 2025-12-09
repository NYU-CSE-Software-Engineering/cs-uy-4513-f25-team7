class MessagesController < ApplicationController
  before_action :ensure_authenticated
  before_action :set_message, only: [:show]

  # GET /messages
  # Inbox: only messages where I'm the recipient
  def index
    @messages = current_user
                  .received_messages
                  .order(created_at: :desc)
  end

  def new
    @message = current_user.sent_messages.build

    recipient = nil
    if params[:recipient_id].present?
      recipient = User.find_by(id: params[:recipient_id])
    elsif params[:recipient_username].present?
      recipient = User.find_by(username: params[:recipient_username])
    end

    if recipient
      @message.recipient          = recipient
      @message.recipient_username = recipient.username
    end
  end

  def create
    username = message_params[:recipient_username].presence
    rid      = message_params[:recipient_id].presence

    recipient =
      if username
        User.find_by(username: username)
      elsif rid
        User.find_by(id: rid)
      end

    @message = current_user.sent_messages.build(
      recipient: recipient,
      subject:   message_params[:subject],
      body:      message_params[:body]
    )

    # So username-based validation can run if needed
    @message.recipient_username = username

    if @message.save
      redirect_to message_path(@message), notice: "Message sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @message.mark_read! if @message.respond_to?(:mark_read!) && @message.read_at.nil?
  end

  private

  def set_message
    @message = Message
                 .where(sender: current_user)
                 .or(Message.where(recipient: current_user))
                 .find(params[:id])
  end

  def message_params
    params.require(:message).permit(:recipient_username, :recipient_id, :subject, :body)
  end
end
