require 'rails_helper'

RSpec.describe Appointment, type: :model do
  #
  # let(:appointment){FactoryGirl.build_stubbed(:appointment)}
  # let(:serialized){ AppointmentSerializer.new(appointment).serializable_hash }
  #
  # it_behaves_like 'a Paranoid model'
  # it_behaves_like 'an API model'
  #
  # it "should serialize correctly" do
  #   expect(serialized.keys).to match_array [:id, :event_type, :event_note, :start_date, :start_time, :end_date, :end_time, :duration, :all_day_event, :session_rate, :repeat_after, :trainer, :clients, :sessions]
  # end

  it "sets a nil next_session date for a single appointment" do
    appt = FactoryGirl.create(:appointment)
    RecurringAppointmentCreator.new(appt).create_sessions
    appt.set_next_session_date
    expect(appt.next_session).to eq(nil)
  end

  it "sets a valid next_session date for a daily appointment" do
    appt = FactoryGirl.create(:daily_appointment, end_date: nil)
    RecurringAppointmentCreator.new(appt).create_sessions
    appt.set_next_session_date
    expect(appt.next_session.to_date).to eq(Date.today+7.day)
  end

  it "sets a valid next_session date for a weekly appointment" do
    appt = FactoryGirl.create(:weekly_appointment, end_date: nil)
    RecurringAppointmentCreator.new(appt).create_sessions
    appt.set_next_session_date
    expect(appt.next_session.to_date).to eq(Date.today+7.week)
  end

  it "sets a valid next_session date for a fortnightly appointment" do
    appt = FactoryGirl.create(:fortnightly_appointment, end_date: nil)
    RecurringAppointmentCreator.new(appt).create_sessions
    appt.set_next_session_date
    expect(appt.next_session.to_date).to eq(Date.today+14.week)
  end

  it "sets a valid next_session date for a monthly appointment" do
    appt = FactoryGirl.create(:monthly_appointment, end_date: nil)
    RecurringAppointmentCreator.new(appt).create_sessions
    appt.set_next_session_date
    expect(appt.next_session.to_date).to eq(Date.today+7.month)
  end

end
