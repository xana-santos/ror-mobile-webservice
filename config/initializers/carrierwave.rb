if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end

CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws' # 'fog/aws' etc. Defaults to 'fog'
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id: "#{ENV['AWS_KEY']}",
    aws_secret_access_key: "#{ENV['AWS_SECRET']}",
    region:                'ap-southeast-2'                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = "#{ENV['AWS_BUCKET_NAME']}"                          # required
  config.fog_public     = true    # optional, defaults to true
  config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}
end
