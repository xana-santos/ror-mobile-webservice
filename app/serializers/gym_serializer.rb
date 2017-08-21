class GymSerializer < BaseSerializer
  attributes :id, :name
  has_many :gym_locations, key: :locations
  
  cached
  
  self.version = 1.2
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
