class V1::ProductsController < ApiController
  include ProductFunctions
  
  def create
    
    check_product_attributes(params) or return
    
    set_product_attributes(params)
    
    product = ::Product.new(params.except(:action, :controller).permit!)
    
    product.save
    
    render json: {id: product.api_token, status: "created"}, status: 200 and return
    
  end
  
  def show
    
    product = ::Product.fetch_by_api_token(params["id"])
    
    check_exists product or return
    
    render json: product, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    filtered = ::Product.filtered(params).order(product_id: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "products", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end
  
  def destroy
    
    if params["id"]
      product = ::Product.fetch_by_api_token(params["id"])
      check_exists product or return
      product.destroy
    elsif params["ids"]
      ::Product.where(api_token: params["ids"]).destroy_all
    end
    
    render json: {status: "deleted"}, status: 200 and return
    
  end
  
  def restore
    
    product = ::Product.only_deleted.find_by(api_token: params["id"])
    
    check_exists product or return
    
    product.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
  def update
    
    product = ::Product.fetch_by_api_token(params["id"])
    
    check_exists product or return
    
    set_update_product_attributes(params, product)
                
    product.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
    
end
