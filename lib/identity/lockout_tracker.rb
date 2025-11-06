module Identity
  class LockoutTracker
    def initialize(max_attempts:, lockout_period:)
      @max_attempts = max_attempts
      @lockout_period = lockout_period
      @failed_attempts = Hash.new(0)
    end

    def record_failed_attempt(email)
      @failed_attempts[email] += 1
      @failed_attempts[email] >= @max_attempts
    end
  end
end
