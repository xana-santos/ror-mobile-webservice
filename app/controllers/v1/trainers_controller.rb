class V1::TrainersController < ApiController
  include TrainerFunctions



  def create
    
    check_trainer_attributes(params) or return

    set_trainer_attributes(params)

    trainer = ::Trainer.new(params.except(:action, :controller).permit!)

    trainer.save
    

    Delayed::Job.enqueue CreateStripeAccountJob.new(trainer, request.ip, trainer.bank_token), queue: 'csv'

    render json: {id: trainer.api_token, status: "created"}, status: 200 and return
  end

  def show
    trainer = ::Trainer.fetch_by_api_token(params["id"])

    check_exists trainer or return

    render json: trainer, root: false, status: 200 and return
  end

  def index

    offset = params[:offset] || 0
    limit = params[:limit] || 25

    filtered = ::Trainer.filtered(params).order(created_at: :asc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}

    render json: filtered, root: "trainers", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return

  end

  def forgot

    trainer = ::Trainer.fetch_by_email(params["email"])

    check_exists trainer or return

    trainer.reset!

    render json: {status: "reset_email_sent"}, root: false, status: 200 and return

  end

  def destroy

    if params["id"]
      trainer = ::Trainer.fetch_by_api_token(params["id"])
      check_exists trainer or return
      trainer.destroy
    elsif params["ids"]
      ::Trainer.where(api_token: params["ids"]).destroy_all
    end

    render json: {status: "deleted"}, status: 200 and return

  end

  def restore

    trainer = ::Trainer.only_deleted.find_by(api_token: params["id"])

    check_exists trainer or return

    trainer.restore!

    render json: {status: "restored"}, status: 200 and return

  end

  def update
    new_stripe_account = params["new_stripe_account"].eql? "true"
    params.delete :new_stripe_account
    trainer = ::Trainer.fetch_by_api_token(params["id"])

    check_exists trainer or return

    set_update_trainer_attributes(params, trainer)

    trainer.update_attributes(params.except(:action, :controller, :id).permit!)
    logger.info ("(--- Trainer update ----)")
    logger.info ("Request new stripe account? #{new_stripe_account}")
    logger.info ((stripe_update_params(trainer) & params.keys).blank?)
    logger.info ("(--- Trainer update ----)")
    if new_stripe_account
      update_stripe_account(trainer, request.ip, trainer.bank_token, params, new_stripe_account)
    end


    update_stripe_account(trainer, request.ip, trainer.bank_token, params) or return unless (stripe_update_params(trainer) & params.keys).blank?

    render json: {status: "updated"}, status: 200 and return

  end

  def deactivate

    trainer = ::Trainer.only_active.find_by(api_token: params["id"])

    check_exists trainer or return

    trainer.deactivate!

    render json: {status: "deactivated"}, status: 200 and return

  end

  def activate

    trainer = ::Trainer.only_inactive.find_by(api_token: params["id"])

    check_exists trainer or return

    trainer.activate!

    render json: {status: "activated"}, status: 200 and return

  end

  def authenticate

    trainer = ::Trainer.fetch_by_email(params["email"])

    if trainer && trainer.authenticate(params[:password])
      render json: {id: trainer.api_token, status: "authenticated"}, status: 200 and return
    else
      show_errors("Invalid email/password") or return
    end

  end

end





