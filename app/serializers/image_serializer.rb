class ImageSerializer < BaseSerializer
  cached
  
  attributes :id, :url, :position, :record
  
  def record
    {id: object.record.api_token, type: object.record_type.underscore}
  end
  
  def include_record?
    @options[:show_record]
  end
  
  self.version = 1.0
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
