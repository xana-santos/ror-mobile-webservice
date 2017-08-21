module StripeConnect
  extend ActiveSupport::Concern

  DEFAULT_CURRENCY = 'aud'
  DEFAULT_COUNTRY = 'AU'

  def stripe_account
    Stripe::Account.retrieve(stripe_id)
  end

  def stripe_secret
    stripe_detail.secret_key rescue nil
  end

  def stripe_customer
    Stripe::Customer.retrieve({id: stripe_id}, stripe_secret)
  end

  def pflo_stripe_customer
    Stripe::Customer.retrieve({id: pflo_stripe_id})
  end

end
