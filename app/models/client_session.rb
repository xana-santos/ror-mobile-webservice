class ClientSession < ActiveRecord::Base
  include ActsAsGraphable
  include Chargeable

  acts_as_paranoid

  attr_accessor :attended

  belongs_to :client
  belongs_to :session, touch: true
  has_one :trainer, through: :session
  has_one :appointment, through: :session

  delegate :first_name, :last_name, :email, to: :client
  delegate :utc_datetime, :date, :time, :session_rate, :duration, to: :session

  scope :by_client, -> (client) { joins(:client).find_by(users: {api_token: client}) }
  scope :by_trainer, -> (trainer) { joins(:trainer).find_by(users: {api_token: trainer}) }

  scope :by_clients, -> (clients) { includes(:client).joins(:client).where(users: {api_token: clients}) }
  scope :by_trainers, -> (trainers) { includes(:trainer).joins(:trainer).where(users: {api_token: trainers}) }

  scope :by_paid, -> (paid){ paid.nil? ? all : where(paid: paid) }

  scope :with_includes, -> { includes([:session, :appointment]) }

  before_save :update_status

  after_save :cancel_client, if: -> (cs){ cs.status_changed? && cs.cancelled? }

  has_one :invoice, as: :record
  has_one :invoice_item, as: :record

  before_save :set_amount, if: -> (cs){ !cs.attended.nil? }

  STATUSES = %w[confirmed rejected cancelled paid attended unattended converted unconverted prospect]

  STATUSES.each do |status|
    define_method("#{status}?"){ self.status == status }
  end

  def update_status
    self.status = (attended ? "attended" : "unattended") unless ["confirmed", "paid", "rejected"].include?(status) unless attended.blank?
  end

  def set_amount
    if session.session_rate.present?
      proper_rate = session.session_rate
    else
      proper_rate = session.appointment.session_rate
    end

    self.amount = ((proper_rate / session.clients.count) * (charge_percent / 100.00)).to_i
  end

  def payment_description
    "Session on #{session.date.strftime("%Y-%m-%d")} at #{session.time} for client #{client.name}"
  end

  def cancel_client
    client.send_sms("#{trainer.first_name} has cancelled your appointment on #{session.date.strftime('%a, %b %d')} at #{session.time}. Thanks! Positiv Flo")
  end

  handle_asynchronously :cancel_client

  def formatted_date
    date.strftime("%d/%m/%Y")
  end

  def confirm!
    update_attributes(status: "confirmed") 
  end

  def reject!
    update_attributes(status: "rejected")
  end

  def to_param
    api_token
  end

  def hours_before_session
    time_diff = TimeDifference.between(DateTime.current.utc, utc_datetime, false).in_hours
  end

  def generate_invoice   
    
    new_invoice = Invoice.new(client: client, trainer: trainer, record: self)
    new_invoice.invoice_items_attributes = [{subtotal: amount, total: charge_amount, record: self, quantity: 1, item: "#{duration} minute session"}]
    client_session_invoice = self.invoice || new_invoice

    if client.client_detail.num_bulk_sessions < 1
      client_session_invoice.attempt_charge
      client_session_invoice.reload
      client_session_invoice.save
      self.invoice = client_session_invoice
      self.save
      reject! unless client_session_invoice.paid
    else
      
      client.client_detail.update_columns(num_bulk_sessions:  client.client_detail.num_bulk_sessions - (charge_percent.to_f / 100 )) 
      update_attributes(status: "paid")
    end

    update_attributes(status: "paid")  if client_session_invoice.paid



  end

  def charge_client_fee
    true
  end

  private

  def invite_message
    url = UrlShortener.new.shorten(url_helpers.session_url(self))

     "#{trainer.first_name} has scheduled a PT session for you on #{session.date.strftime('%a, %b %d')} at #{session.time}. If the time is not suitable visit #{url} to decline. Thanks! Positiv Flo"
  end
end
