# features/step_definitions/message_steps.rb
# Step definitions for direct messaging features

Given('the user {string} has sent me a message {string}') do |name, subject|
  step 'I am signed in'

  sender = user_by_name(name) # helper defined in social_graph_notifications_steps.rb
  Message.create!(
    sender: sender,
    recipient: @current_user,
    subject: subject,
    body: "Body for #{subject}"
  )
end

When('I visit the messages inbox') do
  visit messages_path
end

When('I fill in "Subject" with {string}') do |subject|
  fill_in "Subject", with: subject
end
