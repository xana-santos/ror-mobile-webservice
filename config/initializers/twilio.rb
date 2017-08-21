require 'twilio-ruby'

Twilio.configure do |config|
  config.account_sid = Settings.twilio.sid
  config.auth_token = Settings.twilio.token
end
