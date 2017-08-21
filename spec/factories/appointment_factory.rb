FactoryGirl.define do

  factory :appointment do
    start_date Date.today
    start_time "12:00"
    end_date Date.today + 1.day
    end_time "12:00"
    all_day_event false
    private_event true
    session_rate "5425"
    repeat_after "never"
    event_type "appointment"
    association :trainer
    clients{ [FactoryGirl.create(:client).api_token] }

    factory :daily_appointment do
      repeat_after "day"
    end

    factory :weekly_appointment do
      repeat_after "week"
      end_date Date.today + 7.day

    end

    factory :fortnightly_appointment do
      repeat_after "fortnight"
      end_date Date.today + 14.day

    end

    factory :monthly_appointment do
      repeat_after "month"
      end_date Date.today + 1.month
    end
  end

end
