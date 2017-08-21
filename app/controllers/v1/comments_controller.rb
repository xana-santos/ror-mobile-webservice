class V1::CommentsController < ApiController
  
  def create
    
    client = ::Client.fetch_by_api_token(params["client_id"])
    
    check_exists(client, "client") or return
    
    comment = client.comments.new(params.except(:action, :controller, :client_id).permit!)
    
    comment.save
    
    render json: {id: comment.api_token, status: "created"}, status: 200 and return
    
  end

  def show
    
    comment = ::Comment.fetch_by_api_token(params["id"])
    
    check_exists comment or return
    
    render json: comment, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    if params["trainer_id"]
      trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
      check_exists(trainer, "trainer") or return
      comments = trainer.comments
    elsif params["client_id"]
      client = ::Client.fetch_by_api_token(params["client_id"])
      check_exists(client, "client") or return
      comments = client.comments
    else
      comments = ::Comment.all
    end
    
    filtered = comments.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "comments", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end

  def update
    
    comment = ::Comment.fetch_by_api_token(params["id"])
    
    check_exists comment or return
                
    comment.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end

  def destroy
    
    if params["id"]
      comment = ::Comment.fetch_by_api_token(params["id"])
      check_exists comment or return
      comment.destroy
    elsif params["ids"]
      ::Comment.where(api_token: params["ids"]).destroy_all
    end
    
    render json: {status: "deleted"}, status: 200 and return
    
  end

  def restore
    
    comment = ::Comment.only_deleted.find_by(api_token: params["id"])
    
    check_exists comment or return
    
    comment.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
end
