class V1::InvoicesController < ApiController
  include InvoiceFunctions

  def show

    invoice = ::Invoice.fetch_by_api_token(params["id"])

    check_exists invoice or return

    render json: invoice, root: false, status: 200 and return

  end

  def index
    logger.info('Invoice controller index called');

    offset = params[:offset] || 0
    limit = params[:limit] || 25

    invoices = ::Invoice.by_record(params["record_type"], params["record_id"]).by_associations(params)

    filtered = invoices.filtered(params).order(created_at: :desc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}

    render json: filtered, root: "invoices", meta: metadata, status: 200 and return

  end

  def csv

    trainer = ::Trainer.fetch_by_api_token(params["trainer_id"])
    check_exists(trainer, "trainer") or return

    Delayed::Job.enqueue SendCsvJob.new(trainer, params), queue: 'csv'

    render json: {status: "sending"}, status: 200 and return

  end

  def retry

    invoice = ::Invoice.fetch_by_api_token(params["id"])

    check_exists(invoice, "invoice") or return

    show_errors("Invoice has already been paid.") if invoice.paid

    invoice.attempt_charge

    invoice.reload

    render json: {status: (invoice.paid ? "succeeded" : "failed"), paid: invoice.paid, payment_details: invoice.payment_details}, root: false, status: 200 and return

  end

end
