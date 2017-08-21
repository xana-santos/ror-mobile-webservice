class V1::ConsultationsController < ApiController
  include ConsultationFunctions
  
  def create
    
    client = ::Client.fetch_by_api_token(params["client_id"])
    
    check_exists(client, "client") or return
    
    set_consultation_attributes(params)
    
    consultation = client.consultations.new(params.except(:action, :controller, :client_id).permit!)
    
    consultation.save
    
    render json: {id: consultation.api_token, status: "created"}, status: 200 and return
    
  end

  def show
    
    consultation = ::Consultation.fetch_by_api_token(params["id"])
    
    check_exists consultation or return
    
    render json: consultation, root: false, status: 200 and return
    
  end
  
  def index
    
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    
    if params["trainer_id"]
      trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
      check_exists(trainer, "trainer") or return
      consultations = trainer.consultations
    elsif params["client_id"]
      client = ::Client.fetch_by_api_token(params["client_id"])
      check_exists(client, "client") or return
      consultations = client.consultations
    else
      consultations = ::Consultation.all
    end

    filtered = consultations.filtered(params).order(created_at: :asc)
    
    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}
    
    render json: filtered, root: "consultations", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
    
  end

  def update
    
    consultation = ::Consultation.fetch_by_api_token(params["id"])
    
    check_exists consultation or return
    
    set_update_consultation_attributes(params, consultation)
                
    consultation.update_attributes(params.except(:action, :controller, :id).permit!)
        
    render json: {status: "updated"}, status: 200 and return
    
  end

  def destroy
    
    if params["id"]
      consultation = ::Consultation.fetch_by_api_token(params["id"])
      check_exists consultation or return
      consultation.destroy
    elsif params["ids"]
      ::Consultation.where(api_token: params["ids"]).destroy_all
    end
        
    render json: {status: "deleted"}, status: 200 and return
    
  end

  def restore
    
    consultation = ::Consultation.only_deleted.find_by(api_token: params["id"])
    
    check_exists consultation or return
    
    consultation.restore!
    
    render json: {status: "restored"}, status: 200 and return
    
  end
  
end