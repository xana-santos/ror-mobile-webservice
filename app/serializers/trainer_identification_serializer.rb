class TrainerIdentificationSerializer < BaseSerializer
  
  cached
  
  attributes :token, :status, :details, :code
  
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << object.cache_key
  end
  
end
