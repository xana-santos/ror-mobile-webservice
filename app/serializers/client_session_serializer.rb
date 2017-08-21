class ClientSessionSerializer < BaseSerializer
  
  attributes :id, :first_name, :last_name, :email, :status, :client_session
  has_one :invoice
  
  cached
  
  def client_session
    {id: object.api_token}
  end
  
  def id
    object.client.api_token
  end
    
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end