class SessionRateSerializer < BaseSerializer
  attributes :id, :session_10, :session_20, :session_30, :session_40, :session_general
  
  cached
  
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
