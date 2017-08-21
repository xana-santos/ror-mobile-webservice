module Verifiable
  extend ActiveSupport::Concern
  
  def to_stripe
    {
      country: StripeConnect::DEFAULT_COUNTRY,
      managed: true,
      email: email,
      statement_descriptor: name,
      default_currency: StripeConnect::DEFAULT_CURRENCY,
      legal_entity: legal_entity
    }
  end
  
  def legal_entity
    
    le = legal_entity_basic
    
    le.merge!({address: legal_entity_address}) unless address.blank?
    
    le.merge!({dob: legal_entity_dob}) if birthdate?
    
    le.merge!({
      verification: legal_entity_verification
    }) unless trainer_identification_token.blank?
    
    return le
    
  end
  
  def legal_entity_address
    {
      line1: address.line_1,
      line2: address.line_2,
      city: address.suburb,
      state: address.state,
      postal_code: address.postcode,
      country: StripeConnect::DEFAULT_COUNTRY
    }
  end
  
  def legal_entity_dob
    {
      day: birthdate.strftime("%d"),
      month: birthdate.strftime("%m"),
      year: birthdate.strftime("%Y")
    }
  end
  
  def legal_entity_verification
    {
      document: trainer_identification_token
    }
  end
  
  def legal_entity_basic
    le_basic = {
      type: "individual"
      # business_name: (gym.name rescue "Unknown")
    }
    le_basic.merge!({business_tax_id: abn}) if abn?
    le_basic.merge!({first_name: first_name, last_name: last_name}) unless identity_verified?
    le_basic
  end
  
  def identity_verified?
    trainer_identification.status == "verified" rescue false
  end

  def update_verification_fields(account)
    identification = account.legal_entity.verification if account.try(:legal_entity).try(:verification)
    verification = account.verification if account.try(:verification)
    status = account.transfers_enabled ? "verified" : "unverified"

    trainer_identification.update_attributes(status: identification.status, code: identification.details_code, details: identification.details) if identification
    trainer_verification.update_attributes(fields_needed: verification.fields_needed, due_by: verification.due_by, disabled_reason: verification.disabled_reason, status: status) if verification
  end
  
end