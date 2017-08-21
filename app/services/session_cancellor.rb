class SessionCancellor
  def initialize(appointment, session)
    @appointment = appointment
    @session = session
  end

  def cancel
    if (@session == @appointment.sessions.first || @session == @appointment.sessions.last)
      @session.destroy
      @appointment.update_attributes({start_date: @appointment.sessions.first.date, end_date: @appointment.sessions.last.date}) unless @appointment.sessions.count.eql? 0
    else
      @session.destroy

      # @first_appointment = @appointment.dup
      # @second_appointment = @appointment.dup

      # @first_appointment.api_token = nil
      # @second_appointment.api_token = nil

      # @first_appointment.save
      # @second_appointment.save
    
      # @first_appointment.sessions = @first_appointment.sessions.where("date < ?", @session.date)
      # @second_appointment.sessions = @first_appointment.sessions.where("date > ?", @session.date)

      # @first_appointment.appointment_clients = @appointment.appointment_clients
      # @second_appointment.appointment_clients = @appointment.appointment_clients

      # @appointment.reload
      # @first_appointment.reload
      # @second_appointment.reload
    
      # @first_appointment.update_attributes({start_date: @first_appointment.sessions.first.date, end_date: @first_appointment.sessions.last.date})
      # @second_appointment.update_attributes({start_date: @second_appointment.sessions.first.date, end_date: @second_appointment.sessions.last.date})
    end
  end
end
