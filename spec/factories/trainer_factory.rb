FactoryGirl.define do
  
  factory :trainer do
    first_name "Test"
    last_name "User"
    sequence(:email, 100) { |n| "person#{n}@example.com" }
    password "password"
    password_confirmation "password" 
    birthdate Date.today - 18.years
    address
    abn "15181618729"
    gym_location
    stripe_id "acct_17AqXUIF3azkDCFP"
    stripe_detail
    trainer_verification
    trainer_identification
    association :profile_image, factory: :image
  end
  
end