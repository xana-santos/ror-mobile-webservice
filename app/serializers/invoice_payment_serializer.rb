class InvoicePaymentSerializer < BaseSerializer
  attributes :id, :subtotal, :total, :fees, :description, :paid, :attempts, :payment_details
  
  has_many :invoice_items, key: :items, serializer: InvoiceItemPaymentSerializer
  
  cached
  
  self.version = 1.1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end
  
end