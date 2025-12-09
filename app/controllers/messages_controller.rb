class MessagesController < ApplicationController
  before_action :ensure_authenticated
  before_action :set_message, only: [:show]

  def index
    # Inbox: only messages where the current user is the recipient
    @messages = current_user.received_messages.order(created_at: :desc)
  end

  def new
    if params[:recipient_username].present?
      @recipient = User.find_by(username: params[:recipient_username])
    end

    @message = Message.new(recipient: @recipient)
  end


  def create
    # Sender is always the current signed-in user
    @message = current_user.sent_messages.build(message_params)

    if @message.save
      flash[:notice] = "Message sent."
      redirect_to message_path(@message)
    else
      flash.now[:alert] = "Unable to send messages."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # Only sender or recipient can view the messages
    unless [@message.sender_id, @message.recipient_id].include?(current_user.id)
      head :not_found and return
    end

    # Mark as read when the recipient views it
    if @message.recipient_id == current_user.id && @message.read_at.nil?
      @message.mark_read!
    end
  end

  private

  def set_message
    # Look up only within messages involving the current user
    @message = Message
                 .where(sender_id: current_user.id)
                 .or(Message.where(recipient_id: current_user.id))
                 .find(params[:id])
  end

  def message_params
    params.require(:message).permit(:recipient_id, :subject, :body)
  end
end
