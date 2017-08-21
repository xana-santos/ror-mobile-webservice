module Repeatable
  require 'time_difference'
  extend ActiveSupport::Concern

  def time_changes
    !(["repeat_after", "start_date", "start_time", "end_date", "end_time"] & (self.changes.keys)).blank?
  end

  def offset
    # should not use GMT offset as it does not cater for daylight savings.
    gym_location.offset rescue "+00:00"
  end

  def timezone
    gym_location.timezone rescue "UTC"
  end

  def start_time_with_default
    start_time || "00:00"
  end

  def end_time_with_default
    end_time || "00:00"
  end

  def get_utc_datetime(date, time, time_zone='UTC')
    ActiveSupport::TimeZone[time_zone].parse("#{date} #{time}").utc unless date.blank?
  end

  def start_utc
    get_utc_datetime(start_date, start_time_with_default, timezone)
  end

  def next_session_date
    next_session.in_time_zone(timezone).to_date
  end

  def end_utc
    get_utc_datetime(end_date, end_time_with_default, timezone)
  end

  def set_next_session(from_time=DateTime.current.utc)
    self.next_session = get_next_session(from_time)
  end

  def get_next_session(from_time=DateTime.current.utc)

    unless no_next_session?(from_time)
      next_sess = (start_utc > from_time) ? start_utc : calculate_closest_date(from_time)
      next_sess = ((next_sess > end_utc) ? nil : next_sess) unless next_sess.blank?
    end

    next_sess

  end

  def no_next_session?(from_time=DateTime.current.utc)
    (!end_utc.blank? && end_utc < from_time) || start_utc.blank?
  end

  def calculate_closest_date(from_time=DateTime.current.utc)

    time_diff = TimeDifference.between(from_time, start_utc)

    time_between = { "day" => time_diff.in_days, "week" => time_diff.in_weeks, "fortnight" => (time_diff.in_fortnights), "month" => time_diff.in_months.to_i}

    if time_between[repeat_after]
      next_interval = (start_utc + time_between[repeat_after].to_i.send("#{repeat_after}"))
      return (next_interval > from_time) ? next_interval : (next_interval + 1.send("#{repeat_after}"))
    else
      return nil
    end

  end

end
