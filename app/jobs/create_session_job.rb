class CreateSessionJob

  def perform
    session_time = DateTime.current.utc + 48.hours

    # Appointment.where(event_type: "appointment").each do |appt|
    #   if appt.next_session <= session_time
    #     RecurringAppointmentCreator.new(appt).create_next_session
    #     appt.set_next_session_date
    #   end
    # end
  end

  def error(job, exception)

  end

  def reschedule_at(time, attempts)
    time + (Fibonacci.new.get(attempts)).minutes
  end

  def failure_details
    {
      "Error" => "Failed to check for appointment reminder"
    }
  end

  def max_attempts
    5
  end

end
