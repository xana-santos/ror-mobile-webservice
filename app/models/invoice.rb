class Invoice < ActiveRecord::Base
  include RecordTokenable
  include IdentityCache
  include Taxable

  acts_as_paranoid

  cache_index :api_token, unique: true

  belongs_to :trainer
  belongs_to :client

  belongs_to :record, -> { (try(:with_includes) || all) }, polymorphic: true

  has_many :invoice_items, dependent: :destroy
  accepts_nested_attributes_for :invoice_items

  has_many :invoice_items_without_shipping, -> { where.not(item: ["Shipping Fee"]) }, class_name: InvoiceItem

  scope :by_associations, -> (filters={}){ by_trainer(filters["trainer_id"]).by_client(filters["client_id"]) }

  scope :by_client, -> (client){ client.blank? ? all : joins(:client).where(users: {api_token: client}).references(:client) }
  scope :by_trainer, -> (trainer){ trainer.blank? ? all : joins(:trainer).joins("INNER JOIN users trainers ON trainers.id = invoices.trainer_id AND trainers.type IN ('Trainer')").where(trainers: {api_token: trainer}).references(:trainer) }

  scope :by_date, -> (start_date=nil, end_date=nil){ starting_from(start_date).ending_by(end_date) }
  scope :starting_from, -> (start_date){ start_date.blank? ? all : where("created_at >= ?", start_date) }
  scope :ending_by, -> (end_date){ end_date.blank? ? all : where("created_at <= ?", end_date) }

  default_scope { includes(:invoice_items) }

  before_create :set_trainer_fees

  def description
    invoice_items.collect(&:description).join("\n")
  end

  def csv_description
    case record_type
    when "ClientSession"
      "PT session for #{client.name}"
    when "Purchase"
      "Purchase for #{client.name}"
    end
  end

  def self.as_csv
    CSV.generate do |csv|

      csv << ["Date", "Session Date", "Session Time", "Session Duration (min)",	"Amount (ex GST)", "GST", "Amount", "Payee Description", "Description", "Client Name",	"Reference", "Revenue Type"]

      all.includes([:record, :client, :invoice_items_without_shipping]).each do |invoice|

        invoice.invoice_items_without_shipping.each do |invoice_item|
          attributes =  []
          attributes << invoice.created_at.strftime("%d/%m/%Y")
          attributes << invoice.try(:record).try(:date).try(:strftime, "%d/%m/%Y")
          attributes << invoice.try(:record).try(:time)
          attributes << invoice.try(:record).try(:duration)
          attributes << invoice_item.subtotal_ex_gst.precision(2) if invoice.try(:trainer).try(:gst)
          attributes << invoice_item.subtotal_gst.precision(2) if invoice.try(:trainer).try(:gst)
          attributes << invoice_item.subtotal_dollars.precision(2)
          attributes << "Positiv Flo Pty Ltd"
          attributes << invoice.csv_description
          attributes << invoice.client.name
          attributes << invoice.stripe_id
          attributes << invoice.record_type
          csv << attributes
        end

        #fees
        attributes =  []

        attributes << invoice.created_at.strftime("%d/%m/%Y")
        attributes << nil
        attributes << nil
        attributes << nil
        attributes << invoice.trainer_fees_ex_gst.negate.precision(2)
        attributes << invoice.trainer_fees_gst.negate.precision(2)
        attributes << invoice.trainer_fee_dollars.negate.precision(2)
        attributes << "Positiv Flo Pty Ltd"
        attributes << "Positiv Flo Fee"
        attributes << nil
        attributes << invoice.stripe_id
        attributes << "Fee"

        csv << attributes

      end

    end
  end

  def purchase_order_csv
    CSV.generate do |csv|

      csv << ["Order Number", "Client Name", "Client Address", "Order details",	" Total order amount", "Order Commission 10%", "Trainer Name"]

      subtotal = 0
      order_details = ""
      self.invoice_items_without_shipping.each do |invoice_item|
        subtotal += invoice_item.subtotal_dollars.precision(2).to_f
        order_details += "#{invoice_item.quantity} x #{invoice_item.item}"
        order_details += " "
      end

      main_address = self.client.main_address
      attributes =  []
      attributes << 1
      attributes << self.client.name
      attributes << "#{main_address.line_1}, #{main_address.line_2}, #{main_address.suburb}, #{main_address.postcode}, #{main_address.state}"
      attributes << order_details
      attributes << subtotal
      attributes << subtotal*0.1
      attributes << self.trainer.name
      csv << attributes

    end
  end

  def set_trainer_fees
    self.trainer_fees = (Settings.fees.trainer*gst_multiplier).round
  end

  def trainer_fees_ex_gst
    (trainer_fee_dollars*ex_gst_multiplier).round(2)
  end

  def trainer_fees_gst
    (trainer_fee_dollars*Settings.fees.gst_percent).round(2)
  end

  def fees
    invoice_items.collect(&:fees).sum
  end

  def fees_ex_gst
    invoice_items.collect(&:fees_ex_gst).sum
  end

  def fees_gst
    invoice_items.collect(&:fees_gst).sum
  end

  def total
    invoice_items.collect(&:total).sum
  end

  def subtotal
    invoice_items.collect(&:subtotal).sum
  end

  def subtotal_ex_gst
    invoice_items.collect(&:subtotal_ex_gst).sum
  end

  def subtotal_gst
    invoice_items.collect(&:subtotal_gst).sum
  end

  def subtotal_dollars
    subtotal/100.00
  end

  def total_dollars
    total/100.00
  end

  def trainer_fee_dollars
    trainer_fees/100.00
  end

  def fees_dollars
    fees/100.00
  end

  def attempt_charge

    if record.charge_percent.zero?
      record.attended = nil unless record.try(:attended).nil?
      record.update_attributes(status: "paid", updated_at: Time.now)
      update_attributes(paid: true, payment_details: "Payment successful")
      return
    end

    unless client.pflo_stripe_id.blank?
      begin
        # logger.info ('---')
        # logger.info ('record.charge_amount: ' + record.charge_amount.to_s)
        # logger.info ('record.to_charge: ' + record.to_charge.to_s)
        # logger.info ('---')
        # logger.info ('record.application_fee: ' + record.application_fee.to_s)
        # logger.info ('---')
        # logger.info ('record.session_amount: ' + record.session_amount.to_s)
        # logger.info ('---')
        # logger.info ('record.trainer_fee: ' + record.trainer_fee.to_s)
        # logger.info ('record.trainer_fee_amount: ' + record.trainer_fee_amount.to_s)
        # logger.info ('record.trainer_fee_gst: ' + record.trainer_fee_gst.to_s)
        # logger.info ('---')
        # logger.info ('record.client_fee: ' + record.client_fee.to_s)
        # logger.info ('record.client_fee_amount: ' + record.client_fee_amount.to_s)
        # logger.info ('record.client_fee_gst: ' + record.client_fee_gst.to_s)
        # logger.info ('---')
        # logger.info ('record.stripe_fee: ' + record.stripe_fee.to_s)
        # logger.info ('---')
      
        charge = Stripe::Charge.create({
            amount: record.charge_amount.round,
            application_fee: record.application_fee.round,
            currency: Settings.stripe.default_currency,
            customer: record.client.pflo_stripe_id,
            description: record.payment_description,
            destination: client.trainer.stripe_id,
            statement_descriptor: client.trainer.name,
            metadata: {
              'Client API Token' => client.api_token,
              'Client Name' => client.name,
              'Client Email' => client.email,
              'Client Fee (inc GST)' => record.client_fee,
              'Client Mobile' => client.mobile,
              'Session Amount' => record.session_amount,
              'Trainer API Token' => client.trainer.api_token,
              'Trainer Name' => client.trainer.name,
              'Trainer Email' => client.trainer.email,
              'Trainer Mobile' => client.trainer.mobile,
              'Trainer Fee (inc GST)' => record.trainer_fee,
              'Stripe Percentage Fee' => record.stripe_percent,
              'Stripe Flat Fee' => Settings.fees.stripe,
              'Pflo Client Transaction Fee' => Settings.fees.pflo_trans_fee,
            }
          }
        )
        record.attended = nil unless record.try(:attended).nil?
        record.update_attributes(status: "paid", updated_at: Time.now)
        update_attributes(paid: true, payment_details: "Payment successful", stripe_id: charge.id)

        # Turning this off for now
        # Delayed::Job.enqueue SendPaymentReceiptJob.new(self), queue: "payment_receipt"
      # :nocov:
      rescue Stripe::CardError, Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError => e

        begin
          body = e.json_body
          err  = body[:error]
          err  = err[:message] if err[:message]
        rescue
          err = e
        end

        update_attributes(payment_details: "Error: #{err}")
      rescue => e
        update_attributes(payment_details: "Error: An unknown error occurred. Please try again later.")
      end
      # :nocov:
    else
      update_attributes(payment_details: "Error: Client is not currently set up for Stripe.")
    end

    record.try(:payment_failure) unless paid

    increment!(:attempts)

  end

end
