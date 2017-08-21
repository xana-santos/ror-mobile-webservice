namespace :memcached do
  desc 'Clears the Rails cache'
  task :flush => :environment do

    begin
      Rails.cache.clear
    rescue SystemCallError
    end
    
  end
end