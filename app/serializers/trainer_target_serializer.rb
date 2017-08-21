class TrainerTargetSerializer < BaseSerializer
  
  attributes :id, :earning, :supplement_sales, :holidays, :date, :work_hours
  
  cached
  
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
