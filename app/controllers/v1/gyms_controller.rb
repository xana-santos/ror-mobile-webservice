class V1::GymsController < ApiController
  include GymFunctions
  
  def create
        
    set_gym_attributes(params)
    
    gym = ::Gym.create!(params.except(:action, :controller).permit!)
    
    render json: {id: gym.api_token, status: "created"}, status: 200 and return
    
  end

  def show
    
    gym = ::Gym.fetch_by_api_token(params["id"])
    
    check_exists(gym) or return
    
    render json: gym, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    filtered = ::Gym.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "gyms", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end

  def update
    
    gym = ::Gym.fetch_by_api_token(params["id"])
    check_exists gym or return
    
    set_update_gym_attributes(params, gym)
            
    gym.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
  
  def restore
    
    gym = ::Gym.only_deleted.find_by(api_token: params["id"])
    check_exists gym or return
    
    gym.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end

  def destroy
    
    if params["id"]
      gym = ::Gym.fetch_by_api_token(params["id"])
      check_exists gym or return
      gym.destroy
    elsif params["ids"]
      ::Gym.where(api_token: params["ids"]).destroy_all
    end
        
    render json: {status: "deleted"}, status: 200 and return
    
  end
  
end
