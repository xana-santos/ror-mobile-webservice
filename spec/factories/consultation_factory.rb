FactoryGirl.define do
  
  factory :consultation do
    consultation_date Date.today
    consultation_time "12:00"
    fat_percentage 20.10
    weight 75
    association :client
  end
  
end