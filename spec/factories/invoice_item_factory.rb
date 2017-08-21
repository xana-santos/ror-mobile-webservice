FactoryGirl.define do
  
  factory :invoice_item do |ii|
    quantity 5
    subtotal 6000
    total 6000
    item "45 minute session"
    association :record, factory: :client_session
  end
  
end