class V1::AddressesController < ApiController
  include AddressFunctions
  
  def create
    
    client = ::Client.fetch_by_api_token(params["client_id"])
    
    check_exists(client, "client") or return
        
    address = client.addresses.new(params.except(:action, :controller, :client_id).permit!)
    
    check_main_address address or return
    
    address.save
    
    render json: {id: address.api_token, status: "created"}, status: 200 and return
    
  end
  
  def show
    
    address = ::Address.fetch_by_api_token(params["id"])
    
    check_exists address or return
    
    render json: address, root: false, show_id: true, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    address = ::Address.order(created_at: :asc)
    filtered = address.filtered(params)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
        
    render json: filtered, root: "addresses", show_id: true, show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end
  
  def update
    
    address = ::Address.fetch_by_api_token(params["id"])
    check_exists address or return
    
    check_main_address address or return
        
    address.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
  
  def destroy
    
    if params["id"]
      address = ::Address.fetch_by_api_token(params["id"])
      check_exists address or return
      address.destroy
    elsif params["ids"]
      ::Address.where(api_token: params["ids"]).destroy_all
    end
    
    render json: {status: "deleted"}, status: 200 and return
    
  end

  def restore
    
    address = ::Address.only_deleted.find_by(api_token: params["id"])
    
    check_exists address or return
    
    address.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
end
