Given("I am signed in") do
  # Until real authentication exists, treat this as a no-op.
  @current_user ||= :fake
end
