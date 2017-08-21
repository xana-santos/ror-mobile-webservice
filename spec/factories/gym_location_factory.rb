FactoryGirl.define do
  
  factory :gym_location do
    name "Queen St"
    state "WA"
    association :gym
  end
  
end