module Chargeable
  extend ActiveSupport::Concern

  def 
    charge_amount
    (amount - trainer_fee) + application_fee
  end

  def to_charge
    (amount + client_fee)
  end

  def application_fee
    (trainer_fee + client_fee + stripe_fee)
  end

  def session_amount
    amount
  end

  # Trainer Fee plus GST
  def trainer_fee
    trainer_fee_amount + trainer_fee_gst
  end

  # Trainer Fee excl GST
  def trainer_fee_amount
     s = ""
     self.is_a?(Purchase) ?  s = Settings.fees.trainer.to_s : s = (amount * Settings.fees.trainer_percent).round.to_s   
    # self.is_a?(Purchase) ?  Settings.fees.trainer :
    (amount * Settings.fees.trainer_percent).round     
  end

  # Trainer Fee GST amount
  def trainer_fee_gst
    (trainer_fee_amount * Settings.fees.gst_percent).round
  end

  # Client Fee plus GST
  def client_fee
    client_fee_amount # + client_fee_gst
  end

  # Client Fee excl GST
  def client_fee_amount
    charge_client_fee ? (((amount * Settings.fees.client_percent) + Settings.fees.pflo_trans_fee).round )  : 0
  end

  # Client Fee GST amount
  def client_fee_gst
    (client_fee_amount * Settings.fees.gst_percent).round
  end

  # Stripe fee includes GST
  def stripe_fee
    ((to_charge * stripe_percent) + (Settings.fees.stripe).round)
  end

  def stripe_percent
    client.stripe_percent
  end

  def payment_description
    "Payment for #{self.class} - #{self.api_token}"
  end

end
