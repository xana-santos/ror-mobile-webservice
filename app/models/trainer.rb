class Trainer < User
  acts_as_paranoid
  include StripeConnect
  include Verifiable

  cache_index :api_token, unique: true
  cache_index :email, unique: true

  attr_accessor :gym_location_id, :bank_token

  has_many :sessions, through: :appointments
  has_many :client_sessions, through: :sessions

  has_many :clients
  has_one  :profile_image, as: :record, class_name: Image
  has_one  :identity_image, -> { where(purpose: "identity") }, as: :record, class_name: Image

  has_one :address, as: :record

  has_one :targets, class_name: TrainerTarget

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :profile_image
  accepts_nested_attributes_for :identity_image
  accepts_nested_attributes_for :targets

  has_many :appointments, dependent: :destroy
  has_many :purchases
  has_many :invoices
  has_many :invoice_items, through: :invoices

  has_many :consultations, through: :clients
  has_many :comments, through: :clients
  has_many :products

  has_one :stripe_detail

  has_one :trainer_gym

  has_one :gym, through: :gym_location, dependent: :destroy
  accepts_nested_attributes_for :gym, :allow_destroy => true

  has_one :gym_location, through: :trainer_gym, dependent: :destroy
  accepts_nested_attributes_for :gym_location, :allow_destroy => true

  accepts_nested_attributes_for :clients, :allow_destroy => true
  accepts_nested_attributes_for :stripe_detail

  has_one :trainer_verification
  accepts_nested_attributes_for :trainer_verification

  has_one :trainer_identification
  accepts_nested_attributes_for :trainer_identification


  # referrals
  has_many :refferals, foreign_key: :referrer_id, class_name: "Referral"
  has_many :referees, through: :refferals

  has_one :refferal, foreign_key: :referee_id, class_name: "Referral"
  has_one :referrer, through: :refferal
  accepts_nested_attributes_for :referrer, allow_destroy: true
  accepts_nested_attributes_for :referees, allow_destroy: true
  accepts_nested_attributes_for :refferal, allow_destroy: true
  accepts_nested_attributes_for :refferals, allow_destroy: true

  delegate :token, to: :trainer_identification, allow_nil: true, prefix: true
  delegate :url, to: :identity_image, allow_nil: true, prefix: true

  #after_save :associate_gym

  after_create :send_welcome_email

  def send_welcome_email
    UserMailer.trainer_welcome_email(self).deliver_now
  end
  handle_asynchronously :send_welcome_email

  def to_param
    api_token
  end

  def associate_gym
    unless gym_location_id.blank?

      (gym_identifier = GymLocation.find_by(api_token: gym_location_id).id rescue nil)
      unless gym_identifier.blank?
        tg = TrainerGym.where(trainer_id: self.id).first_or_create
        tg.gym_location_id = gym_identifier
        tg.save
      end

      self.touch

    end
  end

end
