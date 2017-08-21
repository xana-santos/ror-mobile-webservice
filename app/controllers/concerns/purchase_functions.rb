module PurchaseFunctions
  extend ActiveSupport::Concern
  
  private
  
  def set_purchase_attributes(params)      
    products = params["products"]
    product_ids = products.map{|p| p["id"]}
    product_collection = Product.where(api_token: product_ids)
    
    products.each do |p|
      
      product = product_collection.find{|c| c["api_token"] == p["id"]}
      
      show_errors("Product with ID of #{p['id']} does not exist. Please check the ID and try again.") or return if product.blank?
      
      p["product_id"] = product.id
      p["unit_price"] = product.unit_price
      p.delete "id"
      
    end
    
    params["product_purchases_attributes"] = params.delete("products")
    
    return true
    
  end
  
end