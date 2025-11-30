module Identity
  class LockoutTracker
    def initialize(max_attempts:, lockout_period:)
      @max_attempts = max_attempts
      @lockout_period = lockout_period
      @failed_attempts = Hash.new(0)
      @locked_until = {}
    end

    def record_failed_attempt(email)
      return true if locked?(email)

      @failed_attempts[email] += 1
      if @failed_attempts[email] >= @max_attempts
        @locked_until[email] = current_time + @lockout_period
        true
      else
        false
      end
    end

    def locked?(email)
      expires_at = @locked_until[email]
      return false unless expires_at

      if current_time >= expires_at
        @locked_until.delete(email)
        @failed_attempts[email] = 0
        false
      else
        true
      end
    end

    def record_successful_login(email)
      @failed_attempts.delete(email)
      @locked_until.delete(email)
      true
    end

    private

    def current_time
      Time.current
    end
  end
end
