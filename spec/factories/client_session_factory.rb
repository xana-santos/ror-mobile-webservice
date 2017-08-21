FactoryGirl.define do
  
  factory :client_session do
    client
    status "confirmed"
  end
  
end