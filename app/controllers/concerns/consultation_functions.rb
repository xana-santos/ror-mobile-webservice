module ConsultationFunctions
  extend ActiveSupport::Concern
  
  private
  
  def set_consultation_attributes(p)
    p["images_attributes"] = p.delete("images") if p["images"]
  end

  def set_update_consultation_attributes(p, consultation)
    
    if p["images"]
      p["images_attributes"] = p.delete("images")
      consultation.images.each{|a| p["images_attributes"] << {"id" => a.id, "_destroy" => true} }
    end
    
  end
  
end