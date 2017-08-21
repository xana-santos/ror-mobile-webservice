require 'csv'
task :import_gyms => :environment do
  
  files = Dir.glob("#{Rails.root}/config/gyms/**")
  
  files.each do |file|
    
    filename = file.split("/").last
    gym_name = filename.split(".").first.titleize
    
    gym = Gym.find_or_create_by(name: gym_name)
    
    CSV.foreach(file, :headers => true, :encoding => 'ISO-8859-1') do |location|
      
      # Valid columns ["id", "gym_id", "state", "location", "latitude", "longitude", "timezone", "created_at", "updated_at", "deleted_at", "api_token", "phone_number"]
      # CSV headers - UUID,Name,Street Address,Suburb,State,Postcode,Telephone,Latitude,Longitude,Create DateTime,Update DateTime
      
      name = location["Location"]
      address = location["Street Address"]
      suburb = location["Suburb"]
      state = location["State"]
      postcode = location["Postcode"]
      phone = location["Telephone"]
      status = location["Status"]
      
      location = GymLocation.where(gym_id: gym.id, name: (name || suburb)).first_or_create
      
      address_attributes = {line_1: address, suburb: suburb, state: state, postcode: postcode}
      
      location.update_attributes(state: state, phone_number: phone, status: status, address_attributes: address_attributes)
      
    end
    
  end
  
end