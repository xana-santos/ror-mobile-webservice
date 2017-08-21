FactoryGirl.define do
  
  factory :comment do
    comment "Test comment"
    comment_date Date.today
    comment_time "12:00"
    association :client
  end
  
end