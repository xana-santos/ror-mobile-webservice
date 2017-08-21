class GymShortSerializer < BaseSerializer
  attributes :id, :name
  
  cached
  
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
