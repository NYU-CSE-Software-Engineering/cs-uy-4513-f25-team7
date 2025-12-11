Given("I am signed in") do
  # Create a user if not already created
  @current_user ||= User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  # Sign in through the login page
  visit new_user_session_path
  fill_in "Email", with: @current_user.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end
#