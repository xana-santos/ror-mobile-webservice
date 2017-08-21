class BaseSerializer < ActiveModel::Serializer
  attributes :deleted_at
  class_attribute :version, :options
    
  def id
    object.try(:api_token) || object.id
  end
  
  def deleted_at
    object.has_attribute?(:deleted_at) ? (object.deleted_at.blank? ? nil : object.deleted_at.to_i) : nil
  end
  
  def include_deleted_at?
    @options[:show_deleted].blank? ? false : @options[:show_deleted]
  end
  
  self.options = nil
  
  self.version = 1
  
  def self.cache_key
    ['version', self.version]
  end
  
end
