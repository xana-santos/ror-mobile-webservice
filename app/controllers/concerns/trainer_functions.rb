module TrainerFunctions
  extend ActiveSupport::Concern
  include ClientFunctions

  private

  def set_trainer_attributes(p)
    p["address_attributes"] = p.delete("address") if p["address"]
    p["profile_image_attributes"] = p.delete("image") if p["image"]
    p["identity_image_attributes"] = p.delete("identity_image") if p["identity_image"]
    p["targets_attributes"] = p.delete("targets") if p["targets"]
  end

  def check_trainer_attributes(p)

    show_errors({email: "must be unique"}) or return if User.exists?(email: p["email"])

    return true

  end





  def set_update_trainer_attributes(p, trainer)

    if p["image"]
      p["profile_image_attributes"] = p.delete("image")
      p["profile_image_attributes"]["id"] = trainer.profile_image.id if trainer.profile_image
    end

    if p["identity_image"]
      p["identity_image_attributes"] = p.delete("identity_image")
      p["identity_image_attributes"]["id"] = trainer.identity_image.id if trainer.identity_image
    end

    if p["address"]
       p["address_attributes"] = p.delete("address")
       p["address_attributes"]["id"] = trainer.address.id if trainer.address
    end

    p["targets_attributes"] = p.delete("targets") if p["targets"]

  end

  def stripe_update_params(trainer)
    unless trainer.identity_verified?
      ["address", "first_name", "last_name", "bank_token", "verification_token", "abn", "birthdate", "email", "identity_image"]
    else
      ["address", "bank_token", "verification_token", "abn", "email", "identity_image"]
    end
  end

  def setup_stripe_account(trainer, ip, bank_token)




    # Add verification associations
    trainer.create_trainer_identification!
    trainer.create_trainer_verification!

    upload_identity_document(trainer) or return unless trainer.identity_image.blank?

    stripe_info = trainer.to_stripe
    stripe_info.merge!({tos_acceptance: {ip: (ip || "127.0.0.1"), date: Time.now.to_i}})
    stripe_info.merge!({external_account: bank_token}) unless bank_token.blank?

    begin
      account = Stripe::Account.create(stripe_info)
    # :nocov:
    rescue Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError  => e
      show_stripe_error(e) or return
    end
    # :nocov:

    trainer.update_attributes(bank_last_4: account.external_accounts.first.last4) if account.try(:external_accounts) && !account.external_accounts.blank?
    trainer.update_attributes(stripe_id: account["id"])

    trainer.update_verification_fields(account)
    trainer.create_stripe_detail!(secret_key: account["keys"]["secret"], publishable_key: account["keys"]["publishable"]) if account["keys"]
  
    return account

  end

  def update_stripe_account(trainer, ip, bank_token, params={}, new_stripe_account=false)

    account = setup_stripe_account(trainer, ip, bank_token) or return if trainer.stripe_id.blank? || new_stripe_account
    puts "(------- Update stripe account -----)"
    puts "#{trainer.stripe_id}"
    logger.info ("(------- Update stripe account -----)")
    logger.info ("#{trainer.stripe_id}")
    if new_stripe_account
      trainer.clients.each do |c|
        setup_stripe_client(c, nil, nil)
      end
    end

    begin
      account = account ||= trainer.stripe_account

      # Update legal stuffs
      account.email = trainer.email
      account.statement_descriptor = trainer.name

      account.legal_entity.update_attributes(trainer.legal_entity_basic)
      account.legal_entity.address.update_attributes(trainer.legal_entity_address) unless trainer.address.blank?
      account.legal_entity.dob.update_attributes(trainer.legal_entity_dob) unless (trainer.birthdate.blank? || trainer.identity_verified?)

      account.external_account = bank_token unless bank_token.blank?

      unless params["identity_image_attributes"].blank?
        upload_identity_document(trainer) or return unless params["identity_image_attributes"].blank?
        account.legal_entity.verification.update_attributes(trainer.legal_entity_verification) unless trainer.trainer_identification_token.blank?
      end

      account.try(:save)

    # :nocov:
    rescue Stripe::CardError, Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError => e
      show_stripe_error(e) or return
    end
    # :nocov:

    trainer.update_verification_fields(account)

    trainer.update_attributes(bank_last_4: account.external_accounts.first.last4) if account.try(:external_accounts) && !account.external_accounts.blank?

    return true

  end

  def upload_identity_document(trainer)

    begin

      image_url = trainer.identity_image_url

      document = Stripe::FileUpload.create(
        :purpose => 'identity_document',
        :file => open("https://#{Settings.amazon.app_bucket}.s3.amazonaws.com/#{image_url}")
      )
      verification_token = document.try(:id)

    # :nocov:
    rescue Stripe::CardError, Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError => e
      show_stripe_error(e) or return
    end
    # :nocov:

    trainer.trainer_identification.update_attributes(token: verification_token)

    return true

  end

end
