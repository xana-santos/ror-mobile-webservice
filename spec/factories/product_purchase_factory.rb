FactoryGirl.define do
  
  factory :product_purchase do
    association :product
    association :purchase
    quantity 5
    unit_price 12.00
  end
  
end