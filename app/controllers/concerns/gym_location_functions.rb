module GymLocationFunctions
  extend ActiveSupport::Concern
  
  def set_gym_location_attributes(p)
    p["address_attributes"] = p.delete("address") if p["address"]
  end
  
  def set_update_gym_location_attributes(p, location)
    if p["address"]
      p["address_attributes"] = p.delete("address")
      p["address_attributes"]["id"] = location.address.try(:id)
    end
  end
  
end