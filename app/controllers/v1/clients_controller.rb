class V1::ClientsController < ApiController
  include ClientFunctions

  def create

    
    t1 = Time.now
    trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
    check_exists(trainer, "trainer") or return
    check_main_address params["addresses"] or return if params["addresses"]
    set_client_attributes(params)
    client = trainer.clients.new(params.except(:action, :controller, :trainer_id).permit!)

    t2 = Time.now
    delta = t2 - t1 # in seconds

    puts "**** delta for setting up local accounts  " 
    puts delta 




    #Delayed::Job.enqueue CreateStripeAccountJob.new(trainer, request.ip, trainer.bank_token), queue: 'csv'
    
    t1 = Time.now
    setup_stripe_client(client, client.card_token, client.pflo_card_token) or return
    t2 = Time.now
    delta = t2 - t1 # in seconds
    puts "**** delta for settibng up stripe accounts  " 
    puts delta 
    


    t1 = Time.now
    client.save
    t2 = Time.now
    delta = t2 - t1 # in seconds
    puts "**** delta for saving the client " 
    puts delta 

    render json: {id: client.api_token, status: "created"}, status: 200 and return

  end

  def show

    client = ::Client.fetch_by_api_token(params["id"])

    check_exists client or return

    render json: client, root: false, status: 200 and return

  end

  def index

    offset = params[:offset] || 0
    limit = params[:limit] || 25

    if params["trainer_id"]
      trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
      check_exists(trainer, "trainer") or return
      clients = trainer.clients
    else
      clients = Client.all
    end

    filtered = clients.filtered(params).order(created_at: :asc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}

    render json: filtered, root: "clients", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return

  end

  def update
 
    logger.info('##########')
    logger.info('Entered ClientController update')

    logger.info('ClientController update: Get Client: ' + params["id"].to_s);
    client = ::Client.fetch_by_api_token(params["id"])

    logger.info('ClientController update: check_exists');
    check_exists client or return

    logger.info('ClientController update: check_main_address');
    check_main_address params["addresses"] or return if params["addresses"]

    logger.info('ClientController update: set_update_client_attributes');
    set_update_client_attributes(params, client)

    logger.info('ClientController update: client.update_attributes');
    client.update_attributes(params.except(:action, :controller, :id).permit!)

    logger.info('ClientController update: update_stripe_client');
    logger.info('ClientController update: client.card_token: ' + client.card_token.to_s);
    logger.info('ClientController update: client.pflo_card_token: ' + client.pflo_card_token.to_s);
    logger.info("unless: #{(stripe_update_params & params.keys).blank?}")
    update_stripe_client(client, client.card_token, client.pflo_card_token) or return unless (stripe_update_params & params.keys).blank?

    logger.info('ClientController update: render json');
    render json: {status: "updated"}, status: 200 and return

  end

  def destroy

    if params["id"]
      client = ::Client.fetch_by_api_token(params["id"])
      check_exists client or return
      client.destroy
    elsif params["ids"]
      ::Client.where(api_token: params["ids"]).destroy_all
    end

    render json: {status: "deleted"}, status: 200 and return

  end

  def restore

    client = ::Client.only_deleted.find_by(api_token: params["id"])

    check_exists client or return

    client.restore!

    render json: {status: "restored"}, status: 200 and return

  end

  def deactivate

    client = ::Client.only_active.find_by(api_token: params["id"])

    check_exists client or return

    client.deactivate!

    render json: {status: "deactivated"}, status: 200 and return

  end

  def activate

    client = ::Client.only_inactive.find_by(api_token: params["id"])

    check_exists client or return

    client.activate!

    render json: {status: "activated"}, status: 200 and return

  end

  def authenticate

    client = ::Client.fetch_by_email(params["email"])

    if client && client.authenticate(params[:password])
      render json: {id: client.api_token, status: "authenticated"}, status: 200 and return
    else
      show_errors("Invalid email/password") or return
    end

  end

end
