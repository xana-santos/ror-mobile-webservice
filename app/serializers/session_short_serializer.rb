class SessionShortSerializer < SessionSerializer
  has_many :client_sessions, key: :clients, serializer: ClientSessionShortSerializer

  def client_sessions
    object.client_sessions
  end

  def include_appointment?
    false
  end
  
end
