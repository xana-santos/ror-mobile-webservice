require 'bcrypt'

class User < ActiveRecord::Base
  include IdentityCache
  include ActsAsGraphable

  attr_accessor :force_password_update

  cache_index :api_token, unique: true
  cache_index :email, unique: true

  has_secure_password validations: false
  acts_as_paranoid

  has_many :addresses, as: :record, dependent: :destroy

  accepts_nested_attributes_for :addresses,  :allow_destroy => true, :reject_if => :all_blank

  USER_STATUSES =  %w[active inactive]

  scope :only_inactive, -> { where(active: false) }
  scope :only_active, -> { where(active: true) }

  scope :by_subtotal_invoicing, -> (ignored_items=[]) { joins(:invoice_items).select("users.id, users.first_name, users.last_name, SUM(COALESCE(subtotal,0)) as subtotal_sum").order("subtotal_sum DESC").group("users.id, users.first_name, users.last_name").where.not(invoice_items: {item: ignored_items}) }
  scope :by_total_invoicing, -> (ignored_items=[]) { joins(:invoice_items).select("users.id, users.first_name, users.last_name, SUM(COALESCE(total,0)) as total_sum").order("total_sum DESC").group("users.id, users.first_name, users.last_name").where.not(invoice_items: {item: ignored_items}) }

  validates :password, presence: true, confirmation: true, if: -> (obj){ obj.force_password_update }

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def activate!
    update_attributes(active: true)
  end

  def deactivate!
    update_attributes(active: false)
  end

  def to_param
    api_token
  end

  def reset!
    generate_token(:reset_token)
    self.reset_sent = Time.now
    self.send_reset_email
    self.save!
  end

  def send_reset_email
    UserMailer.reset_email(self).deliver_now
  end
  handle_asynchronously :send_reset_email

end
