class Purchase < ActiveRecord::Base
  include IdentityCache
  include Chargeable

  acts_as_paranoid

  cache_index :api_token, unique: true

  belongs_to :trainer
  belongs_to :client

  has_many :product_purchases
  has_many :products, through: :product_purchases
  has_one :invoice, as: :record

  STATUSES = ["unconfirmed", "confirmed", "rejected", "paid", "cancelled"]

  STATUSES.each do |status|
    define_method("#{status}?"){ self.status == status }
  end

  accepts_nested_attributes_for :product_purchases

  scope :after, -> (time){ where("created_at > ?", Time.at(time)) }

  TOP_PERFORMERS = ["Top Products", "Top Trainers"]

  after_create :confirm_purchase
  after_destroy :cancel_purchase

  after_save :set_amount

  def set_amount
    self.update_columns(amount: product_purchases.sum(:total) + Settings.fees.shipping)
  end

  def confirm_purchase
    puts "confirm purchase"
    puts "#{url_helpers.purchase_url(self)}"
    url = Bitly.client.shorten(url_helpers.purchase_url(self)).short_url
    client.send_sms("Hi #{client.name}, we have just received an online purchase from your PT, #{trainer.name}. Please visit #{url} to confirm or reject this order. Thanks! Positiv Flo")
  end
  handle_asynchronously :confirm_purchase

  def cancel_purchase
    puts "cancel purchase"
    update_attributes(status: "cancelled")
    url = Bitly.client.shorten(url_helpers.purchase_url(self)).short_url
    client.send_sms("Your PT, #{trainer.name}, has cancelled an online purchase made for you. Please visit #{url} if you require more information. Thanks! Positiv Flo")
  end
  handle_asynchronously :cancel_purchase

  def generate_invoice

   

    invoice = Invoice.new(client: client, trainer: trainer, record: self)

    invoice_items = []
    

    number_of_product_purchases = product_purchases.length  

    product_purchases.each do |pp|
      invoice_items << {subtotal: pp.amount, total: pp.charge_amount, record: pp, quantity: pp.quantity, item: "#{pp.title}"}
    end

    #shipping = product_purchases.new(unit_price: Settings.fees.shipping, quantity: 0)
    #shipping.set_total

  #  invoice_items << {subtotal: shipping.amount, total: shipping.charge_amount, quantity: shipping.quantity, item: "Shipping Fee"}

   # shipping.destroy

    invoice.invoice_items_attributes = invoice_items

    invoice.save
    invoice.attempt_charge
    send_purchase_order(invoice)
  end
  handle_asynchronously :generate_invoice

  def send_purchase_order(invoice)
    UserMailer.purchase_order_email(invoice.client, invoice.trainer, invoice.purchase_order_csv).deliver_now
  end

  def confirm!
    update_attributes(status: "confirmed")
    generate_invoice
  end

  def charge_percent
    100
  end

  def charge_client_fee
    true
  end

  def reject!
    update_attributes(status: "rejected")
  end

  def to_param
    api_token
  end

  def payment_description
    "Purchase for products #{products.map{|a| a.product_id}.join(', ')}"
  end

  def payment_failure
    url = Bitly.client.shorten(url_helpers.purchase_url(self)).short_url
    client.send_sms("Unfortunately, a payment has failed for an online purchase. Please contact your trainer for more information. Order information: #{url}.")
  end

end
