class AppointmentSerializer < BaseSerializer
  attributes :id, :event_type, :event_note, :start_date, :start_time, :end_date, :end_time, :duration, :all_day_event, :session_rate, :repeat_after, :unconverted_note, :sessions_per_week, :client_value_per_week
  has_one :trainer, serializer: TrainerShortSerializer
  has_many :appointment_clients, serializer: ClientShortSerializer, key: :clients
  has_many :sessions, serializer: SessionShortSerializer

  def start_date
    object.start_date.strftime("%Y-%m-%d") rescue nil
  end

  def end_date
    object.end_date.strftime("%Y-%m-%d") rescue nil
  end

  def sessions
    object.sessions.order(date: :desc, time: :desc)
  end

  cached

  self.version = 1.1

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end

end
