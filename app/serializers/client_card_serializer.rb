class ClientCardSerializer < BaseSerializer  
  attributes :last_4, :brand, :country
  
  cached
    
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
