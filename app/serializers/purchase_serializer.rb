class PurchaseSerializer < BaseSerializer
  attributes :id, :amount, :status
  
  has_many :product_purchases, key: :products
  has_one :trainer, serializer: TrainerShortSerializer
  has_one :client, serializer: ClientShortSerializer
  
  cached
  
  self.version = 1
  
  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end
  
end
