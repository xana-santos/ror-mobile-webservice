FactoryGirl.define do
  
  factory :invoice do
    association :trainer
    association :client
    association :record, factory: :client_session
  end
  
end