class InvoiceItemPaymentSerializer < BaseSerializer
  attributes :id, :quantity, :total, :subtotal, :fees, :item, :description
  
  cached
  
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end
  
end