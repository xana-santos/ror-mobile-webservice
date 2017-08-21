class ProductPurchase < ActiveRecord::Base
  include Chargeable

  acts_as_paranoid

  belongs_to :product, -> { with_deleted }, touch: true
  belongs_to :purchase, touch: true

  before_save :set_total

  def set_total
    self.total = quantity * unit_price
  end

  def amount
    total
  end

  def charge_client_fee
    true
  end

  def stripe_percent
    purchase.client.stripe_percent
  end

  delegate :title, :api_token, to: :product, allow_nil: true

end
