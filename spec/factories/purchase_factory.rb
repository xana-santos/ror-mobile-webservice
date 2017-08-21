FactoryGirl.define do
  
  factory :purchase do
    association :trainer
    association :client
    amount 20.00
  end
  
end