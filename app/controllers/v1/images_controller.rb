class V1::ImagesController < ApiController
  
  def create
    
    record_type = params["record_type"].classify.constantize
    
    record = record_type.fetch_by_api_token(params["record_id"])
    
    check_exists(record, params["record_type"]) or return
        
    image = record.images.new(params.except(:action, :controller, :record_id).permit!)    
    image.save
    
    render json: {id: image.api_token, status: "created"}, status: 200 and return
    
  end
  
  def show
    
    image = ::Image.fetch_by_api_token(params["id"])
    
    check_exists image or return
    
    render json: image, show_record: true, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    filtered = ::Image.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, show_record: true, show_deleted: params[:include_deleted].to_bool, root: "images", meta: metadata, status: 200 and return
    
  end
  
  def update
    
    image = ::Image.fetch_by_api_token(params["id"])
    check_exists image or return
            
    image.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
  
  def destroy
    
    if params["id"]
      image = ::Image.fetch_by_api_token(params["id"])
      check_exists image or return
      image.destroy
    elsif params["ids"]
      ::Image.where(api_token: params["ids"]).destroy_all
    end
        
    render json: {status: "deleted"}, status: 200 and return
    
  end

  def restore
    
    image = ::Image.only_deleted.find_by(api_token: params["id"])
    
    check_exists image or return
    
    image.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
end
