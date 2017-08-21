FactoryGirl.define do

  factory :client do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "person#{n}@example.com" }
    password "password"
    password_confirmation "password"
    client_detail
    trainer
    # stripe_id "cus_7QlIrHALPGTuEU"
    client_card
  end

end
