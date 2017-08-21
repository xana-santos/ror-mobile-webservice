class AddressSerializer < BaseSerializer
  
  attributes :id, :line_1, :line_2, :suburb, :state, :postcode, :main_address, :type
    
  def include_id?
    @options[:show_id] || !["Gym"].include?(object.record_type)
  end
  
  def type
    object.address_type
  end
  
  cached
  
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}-#{@options[:show_id]}"
  end
    
end
