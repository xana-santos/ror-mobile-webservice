FactoryGirl.define do

  factory :session do |session|
    appointment
    client_sessions { build_list :client_session, 1 }
    date (Date.today + 2.days).strftime("%Y-%m-%d")
    time "12:30"
    session_rate 9999
    status "confirmed"
  end

end
