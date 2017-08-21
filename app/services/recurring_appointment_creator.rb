class RecurringAppointmentCreator
  def initialize(appointment)
    @appointment = appointment
    @start_date = appointment.start_date
    @end_date = appointment.end_date || '2037-12-31'
    # @sessions_to_create = 7
  end

  def create_sessions
    repeat_type = @appointment.repeat_after
    return create_daily_sessions if repeat_type.eql? "day"
    return create_weekly_sessions if repeat_type.eql? "week"
    return create_fortnightly_sessions if repeat_type.eql? "fortnight"
    return create_monthly_sessions if repeat_type.eql? "month"
    create_single_session
  end

  def create_next_session
    repeat_type = @appointment.repeat_after
    if repeat_type.eql? "day"
      recurring_dates = Recurrence.new(:every => :day, :starts => @appointment.next_session, :until => @end_date)
    elsif repeat_type.eql? "week"
      recurring_dates = Recurrence.new(:every => :week, :starts => @appointment.next_session, :until => @end_date, :on => @appointment.next_session.wday)
    elsif repeat_type.eql? "fortnight"
      recurring_dates = Recurrence.new(:every => :week, :starts => @appointment.next_session, :until => @end_date, :on => @appointment.next_session.wday, :interval => 2)
    elsif repeat_type.eql? "month"
      recurring_dates = Recurrence.new(:every => :month, :starts => @appointment.next_session, :until => @end_date, :on => @appointment.next_session.mday)
    end
    session = @appointment.sessions.find_or_create_by(date: recurring_dates.events.first)
    session.update_attributes({status: "confirmed"})
  end

  private

  # Use cases
  # As a trainer, I want to cancel a recurring session if the session is on a public holiday.
  # As a trainer, I want to modify the time of every recurring session after a chosen day.
  # As a trainer, I want to modify the day of every recurring session after a chosen day. Given that it is a weekly, fortnightly, monthly recurring session.
  # As a trainer, I want to modify the time of a particular recurring session on a chosen day.
  # As a trainer, I want to create either a daily, weekly, fortnightly, or monthly recurring session.
  # As a trainer, I want to cancel all the recurring sessions.

  def create_single_session
    session = @appointment.sessions.find_or_create_by(date: @start_date)
    session.update_attributes({ date: @start_date, status: "confirmed" })
  end

  def create_daily_sessions
    create_sessions_with_dates(Recurrence.new(:every => :day, :starts => @start_date, :until => @end_date))
  end

  def create_weekly_sessions
    create_sessions_with_dates(Recurrence.new(:every => :week, :starts => @start_date, :until => @end_date, :on => @start_date.wday))
  end

  def create_fortnightly_sessions
    create_sessions_with_dates(Recurrence.new(:every => :week, :starts => @start_date, :until => @end_date, :on => @start_date.wday, :interval => 2))
  end

  def create_monthly_sessions
    create_sessions_with_dates(Recurrence.new(:every => :month, :starts => @start_date, :until => @end_date, :on => @start_date.mday))
  end

  def create_sessions_with_dates(recurring_dates)
    if recurring_dates.count > 100
      raise 'Cannot create more than 100 sessions at time'
    end
    recurring_dates.events.each_with_index do |date, index|
        @appointment.sessions.create(date: date, time: @appointment.start_time, status: "confirmed")
    end
  end
end
