class Client < User
  include StripeConnect
  include Syncable
  include SmsSenderConcern

  acts_as_paranoid

  attr_accessor :card_token, :pflo_card_token

  cache_index :api_token, unique: true
  cache_index :email, unique: true

  cache_index :api_token, :active, unique: true

  has_one :client_detail, foreign_key: :user_id
  accepts_nested_attributes_for :client_detail, allow_destroy: true

  has_many :consultations, dependent: :destroy

  has_many :invoice_items, through: :invoices
  has_many :invoices, dependent: :destroy

  belongs_to :trainer

  has_many :client_appointments, dependent: :destroy
  has_many :appointments, through: :client_appointments, dependent: :destroy

  has_one  :image, as: :record, dependent: :destroy
  has_many :consultation_images, source: :images, through: :consultations

  has_many :comments, dependent: :destroy

  has_one :stripe_detail, through: :trainer

  has_many :purchases, dependent: :destroy

  has_many :client_sessions, dependent: :destroy
  has_many :sessions, through: :client_sessions

  has_one :client_card, dependent: :destroy

  accepts_nested_attributes_for :client_detail

  accepts_nested_attributes_for :consultations,  allow_destroy: true, reject_if: :all_blank

  accepts_nested_attributes_for :comments, allow_destroy: true, reject_if: lambda { |a| a[:body].blank? }

  accepts_nested_attributes_for :image

  has_many :addresses, as: :record
  accepts_nested_attributes_for :addresses, allow_destroy: true

  delegate :id, to: :client_detail, allow_nil: true, prefix: true
  delegate :id, to: :image, allow_nil: true, prefix: true
  delegate :last_4, :brand, :country, allow_nil: true, to: :client_card, prefix: :card

  after_save :send_terms_message, if: -> (obj){ obj.mobile_changed? && !terms_accepted }

  after_create :send_welcome_email

  def send_welcome_email
    UserMailer.client_welcome_email(self).deliver_now
  end
  handle_asynchronously :send_welcome_email

  def to_stripe
    {description: name, email: email}
  end

  def stripe_percent
    percent = 0.0175
    percent = 0.029 if card_brand == "American Express" || card_country != "AU"
    percent
  end

  def main_address
    addresses.find_by(main_address: true)
  end

  def update_stripe(customer=nil, token=nil)

    logger.info('Entered');
    logger.info('Client:update_stripe');
    logger.info('Client:update_stripe customer: ' + customer.to_s);
    logger.info('Client:update_stripe stripe_customer: ' + stripe_customer.to_s);
    logger.info(' CUSTOMER STRIPE TOKEN: ' + token.to_s)
    account = customer || stripe_customer

    account.source = token unless token.nil? # Managed account - customer
    account.try(:save)

    unless account.sources.blank?
      card_details = account.sources.first
      card = client_card || build_client_card
      card.update_attributes(last_4: card_details.last4, brand: card_details.brand, country: card_details.country)
    end
  end

  def update_stripe_account(customer=nil, token=nil)
    logger.info('# # # # # # # # #');
    logger.info('Client:update_stripe_account Entered');
    logger.info('Client:update_stripe_account customer: ' + customer.to_s);
    logger.info('Client:update_stripe_account token: ' + token.to_s);

    pflo_customer = customer || pflo_stripe_customer

    pflo_customer.source = token unless token.nil? # PFLO account - customer

    pflo_customer.description = name
    pflo_customer.email = email
    pflo_customer.try(:save)
  end

  def send_terms_message
    url = Bitly.client.shorten(url_helpers.client_terms_url(self)).short_url
    send_sms("Hi #{name}, Welcome to Positiv Flo, the PT scheduling and billing app. Before we get started please read and accept our T&C’s by visiting #{url}. Thanks! Positiv Flo")
  end
  handle_asynchronously :send_terms_message

  def to_param
    api_token
  end

  def accept_terms!
    update_attributes(terms_accepted: true)
  end

end
