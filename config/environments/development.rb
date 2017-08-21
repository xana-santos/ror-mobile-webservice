PfloRewrite::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.default_url_options = { :host => "http://localhost:3000" }

  config.action_mailer.asset_host = "http://localhost:3000"

  # config.action_mailer.smtp_settings = {
  #     :authentication => :plain,
  #     :address => "smtp.mailgun.org",
  #     :port => 587,
  #     :domain => ENV['EMAIL_DOMAIN'],
  #     :user_name => ENV['EMAIL_USERNAME'],
  #     :password => ENV['EMAIL_PASSWORD']
  # }

  config.action_mailer.perform_deliveries = true

  # Add configuration for mailcatcher
  config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

  config.cache_store = :dalli_store, 'localhost:11211', { namespace: "__ns__Positiv_Flo", pool_size: 5, raise_errors: false }

end