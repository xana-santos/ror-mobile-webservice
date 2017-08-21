module AppointmentFunctions
  extend ActiveSupport::Concern
  
  private
  
  def check_appointment_type(p)
    show_errors({clients: "is required"}) or return if p["event_type"] == "appointment" && p["clients"].blank?
    return true
  end
  
  def check_update_appointment(p, appointment)
    show_errors({clients: "is required"}) or return if appointment.event_type != "appointment" && p["event_type"] == "appointment" && p["clients"].blank?
    return true
  end
  
end