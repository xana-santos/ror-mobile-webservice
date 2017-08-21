class TrainerVerificationSerializer < BaseSerializer
  
  cached
  
  attributes :status, :disabled_reason, :fields_needed, :due_by
    
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end
  
end
