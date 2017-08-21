class V1::StripeController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token

  def events
    logger.info('(------ STRIPE CONTROLLER EVENTS ------)')
    case params["type"]
      when "account.updated"
        account = params["data"]["object"]
        trainer = ::Trainer.find_by(stripe_id: account["id"]) rescue nil
        trainer.update_verification_fields(trainer.stripe_account) if trainer
    end

    render nothing: true, status: 200

  end

end
