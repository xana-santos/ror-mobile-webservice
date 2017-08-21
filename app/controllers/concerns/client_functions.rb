module ClientFunctions
  extend ActiveSupport::Concern

  private

  def set_client_attributes(p)
    p["addresses_attributes"] = p.delete("addresses") if p["addresses"]
    p["client_detail_attributes"] = p.delete("client_details") if p["client_details"]
    p["image_attributes"] = p.delete("image") if p["image"]
    p["stripe_data_attributes"] = p.delete("stripe") if p["stripe"]
  end

  def set_update_client_attributes(p, client)

    if p["client_details"]
      p["client_detail_attributes"] = p.delete("client_details")
      p["client_detail_attributes"]["id"] = client.client_detail_id
    end

    if p["image"]
      p["image_attributes"] = p.delete("image")
      p["image_attributes"]["id"] = client.image_id
    end

    if p["addresses"]
      p["addresses_attributes"] = p.delete("addresses")
      client.addresses.each{|a| p["addresses_attributes"] << {"id" => a.id, "_destroy" => true} }
    end

    p["stripe_data_attributes"] = p.delete("stripe") if p["stripe"]

  end

  def check_main_address(addresses)
    main_number = addresses.count{|a| a["main_address"] == true }
    show_errors("Client can only have one main address. Please remove or update this address first.") or return if main_number > 1
    return true
  end

  def setup_stripe_client(client, card_token, pflo_card_token)


    begin
      stripe_info = client.to_stripe
      stripe_info.merge!({source: card_token}) unless card_token.blank?
      pflo_stripe_info = stripe_info.dup
      pflo_stripe_info.merge!({source: pflo_card_token}) unless pflo_card_token.blank?

  
      customer = Stripe::Customer.create(stripe_info, client.stripe_secret)
      pflo_customer = Stripe::Customer.create(pflo_stripe_info)
     

    # :nocov:
    rescue Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError  => e
      logger.info ('Stripe errors')
      logger.info (e)
      show_stripe_error(e) or return
    end
    # :nocov:


    client.update_attributes(stripe_id: customer.id, pflo_stripe_id: pflo_customer.id)
    unless customer.sources.blank?
      card_details = customer.sources.first
      client_card = client.client_card || client.build_client_card
      client_card.update_attributes(last_4: card_details.last4, brand: card_details.brand, country: card_details.country)
    end

    return customer

  end

  def update_stripe_client(client, card_token, pflo_card_token)

    logger.info('##########')
    logger.info('Entered Client Functions update_stripe_client')
    customer = setup_stripe_client(client, card_token, pflo_card_token) or return unless client.stripe_id?

    begin
      client.update_stripe(customer, card_token)
      client.update_stripe_account(customer, pflo_card_token)
    # :nocov:
    rescue Stripe::InvalidRequestError, Stripe::APIConnectionError, Stripe::StripeError => e
      show_stripe_error(e) or return
    end
    # :nocov:
    return true

  end

  def stripe_update_params
    ["card_token", "pflo_card_token", "email", "first_name", "last_name"]
  end

end
