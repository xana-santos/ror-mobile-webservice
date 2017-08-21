class SessionSerializer < BaseSerializer
  attributes :id, :date, :time, :session_rate, :appointment
  has_many :client_sessions, key: :clients

  cached

  self.version = 1

  def client_sessions
    object.client_sessions.by_paid(@options["paid"])
  end

  def appointment
    {id: object.appointment.api_token} unless object.appointment.nil?
  end

  def date
    object.date.strftime("%Y-%m-%d") rescue nil
  end

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:paid]}-#{object.updated_at.to_i}"
  end

end
