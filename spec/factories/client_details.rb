FactoryGirl.define do
  
  factory :client_detail do
    start_date Date.today
    supplement_only false
    session_duration 1
    session_rate "54.25"
  end
  
end