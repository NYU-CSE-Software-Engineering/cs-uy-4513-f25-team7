# for BBD testing
require 'rotp'

module TestTwoFactorHelper
  # Returns a current valid TOTP code for the given secret.
  def totp_code_for(secret)
    ROTP::TOTP.new(secret).now
  end
end

World(TestTwoFactorHelper)