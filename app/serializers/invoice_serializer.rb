class InvoiceSerializer < BaseSerializer
  attributes :id, :generated, :subtotal, :total, :fees, :description, :paid, :attempts, :payment_details, :record
  
  has_many :invoice_items, key: :items
  
  has_one :trainer, serializer: TrainerShortSerializer
  has_one :client, serializer: ClientShortSerializer
  
  cached
  
  def record
    {type: object.record_type.underscore, id: object.record_token}
  end  
  
  def generated
    object.created_at.to_i
  end
  
  self.version = 1.2
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{object.updated_at.to_i}"
  end
  
end
