require 'bitly'

Bitly.use_api_version_3

Bitly.configure do |config|
  config.api_version = 3
  config.access_token = ENV['BITLY_TOKEN']
end

Rails.application.routes.default_url_options[:host] = Settings.main_host