class V1::ProductCategoriesController < ApiController
  include ProductCategoryFunctions
  
  def create
    
    check_product_category_attributes(params) or return
    
    product_category = ::ProductCategory.new(params.except(:action, :controller).permit!)
    
    product_category.save
    
    render json: {id: product_category.api_token, status: "created"}, status: 200 and return
    
  end
  
  def show
    
    product_category = ::ProductCategory.fetch_by_api_token(params["id"])
    
    check_exists product_category or return
    
    render json: product_category, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    filtered = ::ProductCategory.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "product_categories", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end
  
  def destroy
    
    if params["id"]
      product_category = ::ProductCategory.fetch_by_api_token(params["id"])
      check_exists product_category or return
      product_category.destroy
    elsif params["ids"]
      ::ProductCategory.where(api_token: params["ids"]).destroy_all
    end
        
    render json: {status: "deleted"}, status: 200 and return
    
  end
  
  def restore
    
    product_category = ::ProductCategory.only_deleted.find_by(api_token: params["id"])
    
    check_exists product_category or return
    
    product_category.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
  def update
    
    product_category = ::ProductCategory.fetch_by_api_token(params["id"])
    
    check_exists product_category or return
                
    product_category.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
  
end
