FactoryGirl.define do
  
  factory :user do
    first_name "Test"
    last_name "User"
    sequence(:email, 100) { |n| "person#{n}@example.com" }
    password "password"
    password_confirmation "password"
  end  
  
end