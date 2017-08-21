class CreateStripeAccountJob < Struct.new(:trainer, :ip, :bank_token)
    include TrainerFunctions
    
  def perform
     setup_stripe_account(trainer, ip, bank_token )
  end

  def failure_details
    {
      "Error" => "Failed to create Stripe Account for trainer " + trainer 
    }
  end

  def max_attempts
    3
  end


end