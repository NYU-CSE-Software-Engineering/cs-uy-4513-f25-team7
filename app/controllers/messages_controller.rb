# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  # In test, authenticate_user! is a no-op, so we still guard explicitly
  before_action :authenticate_user!, only: [:index, :new, :create, :show]

  def index
    # Explicit guard so both RSpec and Cucumber see the right redirect / flash
    unless current_user
      redirect_to new_user_session_path, alert: "Please sign in to continue"
      return
    end

    @messages = current_user
                  .received_messages
                  .includes(:sender)
                  .order(created_at: :desc)
  end

  def new
    unless current_user
      redirect_to new_user_session_path, alert: "Please sign in to continue"
      return
    end

    @message = Message.new

    # If coming from a profile page, pre-fill the recipient
    if params[:recipient_id].present?
      @message.recipient = User.find_by(id: params[:recipient_id])
    end
  end

  def show
    unless current_user
      redirect_to new_user_session_path, alert: "Please sign in to continue"
      return
    end

    @message = Message.find(params[:id])

    # Only sender or recipient can view the message
    unless [@message.sender_id, @message.recipient_id].include?(current_user.id)
      redirect_to messages_path, alert: "Not authorized"
      return
    end

    # Mark as read when the recipient views it
    @message.mark_read! if @message.recipient == current_user
  end

  def create
    unless current_user
      redirect_to new_user_session_path, alert: "Please sign in to continue"
      return
    end

    @message = Message.new
    @message.sender = current_user

    # 1) Prefer recipient_id (used by your request specs and hidden field)
    if params[:message][:recipient_id].present?
      @message.recipient = User.find_by(id: params[:message][:recipient_id])
      # 2) Fallback: look up by email if using the email field
    elsif message_params[:recipient_email].present?
      @message.recipient = User.find_by(email: message_params[:recipient_email])
    end

    @message.subject = message_params[:subject]
    @message.body    = message_params[:body]

    if @message.recipient.nil?
      @message.errors.add(:recipient, "must exist")
      render :new, status: :unprocessable_entity
    elsif @message.save
      # IMPORTANT: redirect to the show page so Cucumber sees the subject
      # and RSpec expectation `redirect_to(message_path(Message.last))` passes
      redirect_to message_path(@message), notice: "Message sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    # recipient_email is a virtual attribute; recipient_id is an actual foreign key
    params
      .require(:message)
      .permit(:subject, :body, :recipient_email, :recipient_id)
  end
end
