class CommentSerializer < BaseSerializer
  attributes :id, :comment, :comment_date, :comment_time
  has_one :client, serializer: ClientShortSerializer
  has_one :trainer, serializer: TrainerShortSerializer
  
  def comment_date
    object.comment_date.strftime("%Y-%m-%d") rescue nil
  end
  
  cached
  
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
