class V1::GymLocationsController < ApiController
  include GymLocationFunctions
  
  def create
    
    gym = ::Gym.fetch_by_api_token(params["gym_id"])
    
    check_exists(gym, "gym") or return
    
    set_gym_location_attributes(params)
    
    gym_location = gym.gym_locations.create!(params.except(:action, :controller).permit!)
    
    render json: {id: gym_location.api_token, status: "created"}, status: 200 and return
    
  end

  def show
    
    gym_location = ::GymLocation.fetch_by_api_token(params["id"])
    
    check_exists(gym_location) or return
    
    render json: gym_location, show_gym: true, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    filtered = ::GymLocation.by_associations(params).filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "gym_locations", show_gym: true, show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end

  def update
    
    gym_location = ::GymLocation.fetch_by_api_token(params["id"])
    check_exists gym_location or return
    
    set_update_gym_location_attributes(params, gym_location)
                
    gym_location.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end
  
  def restore
    
    gym_location = ::GymLocation.only_deleted.find_by(api_token: params["id"])
    check_exists gym_location or return
    
    gym_location.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end

  def destroy
    
    if params["id"]
      gym_location = ::GymLocation.fetch_by_api_token(params["id"])
      check_exists gym_location or return
      gym_location.destroy
    elsif params["ids"]
      ::GymLocation.where(api_token: params["ids"]).destroy_all
    end
        
    render json: {status: "deleted"}, status: 200 and return
    
  end
  
end
