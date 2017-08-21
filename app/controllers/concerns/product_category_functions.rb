module ProductCategoryFunctions
  extend ActiveSupport::Concern
  
  private
  
  def check_product_category_attributes(params)    
    show_errors({category: "already exists in the system. Please try another."}) or return unless ProductCategory.find_by(category: params["category"]).blank?
    return true
  end
  
end