class GymLocationSerializer < BaseSerializer
  attributes :id, :name, :street_address, :suburb, :state, :postcode, :phone_number, :status
  has_one :gym, serializer: GymShortSerializer
  
  def include_gym?
    @options[:show_gym]
  end
  
  def status
    object.status.try(:underscore)
  end
  
  cached
  
  self.version = 1.51
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
