class V1::PurchasesController < ApiController
  include PurchaseFunctions

  def create
    
    trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])

    check_exists(trainer, "trainer") or return

    client = ::Client.fetch_by_api_token(params["client_id"])

    check_exists(client, "client") or return

    set_purchase_attributes(params) or return

    params["client_id"] = client.id

    purchase = trainer.purchases.new(params.except(:action, :controller, :trainer_id).permit!)

    purchase.save

    render json: {id: purchase.api_token, status: "created"}, status: 200 and return

  end

  def show

    purchase = ::Purchase.fetch_by_api_token(params["id"])

    check_exists purchase or return

    render json: purchase, root: false, status: 200 and return

  end

  def destroy

    if params["id"]
      purchase = ::Purchase.fetch_by_api_token(params["id"])
      check_exists purchase or return
      show_errors("This purchase cannot be removed") or return unless purchase.unconfirmed?
      purchase.destroy
    elsif params["ids"]
      ::Purchase.where(api_token: params["ids"], status: "unconfirmed").destroy_all
    end

    render json: {status: "deleted"}, status: 200 and return

  end

  def restore

    purchase = ::Purchase.only_deleted.find_by(api_token: params["id"])

    check_exists purchase or return

    purchase.restore!

    render json: {status: "restored"}, status: 200 and return

  end

  def cancel

    purchase = ::Purchase.find_by(api_token: params["id"])

    check_exists purchase or return

    show_errors("This purchase cannot be cancelled") or return unless purchase.unconfirmed?

    purchase.reject!

    render json: {status: "cancelled"}, status: 200 and return

  end

  def index

    offset = params[:offset] || 0
    limit = params[:limit] || 25

    show_errors("Please provide only a client_id or a trainer_id") or return if params["trainer_id"] && params["client_id"]

    if params["trainer_id"]
      trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
      check_exists(trainer, "trainer") or return
      purchases = trainer.purchases
    elsif params["client_id"]
      client = ::Client.fetch_by_api_token(params["client_id"])
      check_exists(client, "client") or return
      purchases = client.purchases
    else
      purchases = ::Purchase.all
    end

    filtered = purchases.filtered(params).order(created_at: :asc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}

    render json: filtered, root: "purchases", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return

  end

  def confirm

    purchase = ::Purchase.fetch_by_api_token(params["id"])

    check_exists purchase or return

    show_errors("This purchase cannot be confirmed.") or return unless purchase.unconfirmed?

    purchase.confirm!

    render json: {status: "confirmed"}, status: 200 and return

  end

  def resend

    purchase = ::Purchase.fetch_by_api_token(params["id"])

    check_exists purchase or return

    show_errors("This purchase has already been responded to.") or return unless purchase.unconfirmed?

    purchase.confirm_purchase

    render json: {status: "resent"}, status: 200 and return

  end

end
