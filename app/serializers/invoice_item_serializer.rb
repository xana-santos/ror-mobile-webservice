class InvoiceItemSerializer < BaseSerializer
  attributes :id, :quantity, :total, :subtotal, :fees, :item, :description, :record
  
  cached
  
  self.version = 1
  
  def record
    {type: object.record_type.underscore, id: object.record_token} if object.record
  end
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end
  
end
