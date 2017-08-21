class ProductSerializer < BaseSerializer
  attributes :id, :title, :description, :product_id, :unit_price, :unit_type, :status, :out_of_stock, :cost, :product_image

  has_many :product_categories, key: :categories

  cached

  self.version = 1

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end

end
