class GymLocationAddressSerializer < BaseSerializer
  
  attributes :line_1, :line_2, :suburb, :state, :postcode
  
  cached
  
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}-#{@options[:show_id]}"
  end
    
end
