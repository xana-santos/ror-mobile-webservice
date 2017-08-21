module GymFunctions
  extend ActiveSupport::Concern
  
  private
  
  def set_gym_attributes(p)
    
    p["gym_locations_attributes"] = p.delete("locations") if p["locations"]
    
    p["gym_locations_attributes"].each do |l|
      l["address_attributes"] = l.delete("address") if l["address"]
    end
    
  end

  def set_update_gym_attributes(p, gym)
    p["gym_locations_attributes"] = p.delete("locations") if p["locations"]
    
    p["gym_locations_attributes"].each do |l|
      l["address_attributes"] = l.delete("address") if l["address"]
    end
    
  end  
  
end