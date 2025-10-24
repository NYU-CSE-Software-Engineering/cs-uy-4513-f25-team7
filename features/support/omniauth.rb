# for BBD testing
require 'omniauth'

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
  provider: 'google_oauth2',
  uid: '123545',
  info: { email: 'oak@pokemon.com', name: 'Professor Oak' }
)