class ClientPaymentSerializer < BaseSerializer

  cached

  attributes :id, :status, :client_session
  has_one :invoice, serializer: InvoicePaymentSerializer

  def client_session
    {id: object.api_token}
  end

  def id
    object.client.api_token
  end

  self.version = 1.1

  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end

end
