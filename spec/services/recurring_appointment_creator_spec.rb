  require 'rails_helper'

RSpec.describe RecurringAppointmentCreator do
  before do
    allow_any_instance_of(UrlShortener).to receive(:shorten).and_return('blah')
    allow_any_instance_of(SmsSender).to receive(:send)
    travel_to Time.utc(2017, 5, 1, 9, 10)
  end

  after { travel_back }

  # Need to comment out client.send_sms in client_session.invite_client
  # to get tests to pass.
  describe '#create_sessions' do
    def create_sessions(appointment)
      RecurringAppointmentCreator.new(appointment).create_sessions
    end

    shared_examples 'correctly created sessions' do
      it 'creates the first session on the start date and time' do
        create_sessions appointment
        expect(appointment.sessions.first.date).to eq(appointment.start_date)
      end

      it 'all created sessions are confirmed' do
        create_sessions appointment

        appointment.sessions.each do |s|
          expect(s.status).to eq('confirmed')
        end
      end

      it 'all created sessions have client sessions for each client' do
        create_sessions appointment

        appointment.sessions.each do |s|
          expect(s.client_sessions.count).to eq(appointment.appointment_clients.count)
        end
      end
    end

    let(:date_start) { Date.today }

    context 'recurring daily appointment' do
      let(:date_end) {  Date.today + 3.months }
      let(:appointment) {  FactoryGirl.create(:daily_appointment,
          start_date: date_start,
          end_date:   date_end)
      }

      it 'creates a session for each day between start and end date inclusive' do
        # inclusive days
        diff = (date_end - date_start) + 1
        expect {
          create_sessions appointment
        }.to change{ appointment.sessions.count }.by(diff.to_i)
      end

      it_should_behave_like 'correctly created sessions'
    end

    context 'recurring weekly appointment' do
      let(:date_end) {   date_start + 3.months + 2.days }
      let(:appointment) {  FactoryGirl.create(:weekly_appointment,
          start_date: date_start,
          end_date:   date_end)
      }

      it 'creates a session on the same day each week between start and end date' do
        expect {
          create_sessions appointment
        }.to change{ Session.count }.by(14)
      end

      it_should_behave_like 'correctly created sessions'
    end

    context 'recurring fortnightly appointment' do
      let(:date_end) {   date_start + 3.months + 2.days }
      let(:appointment) {  FactoryGirl.create(:fortnightly_appointment,
          start_date: date_start,
          end_date:   date_end)
      }

      it 'creates a session on the same day every 2 weeks between start and end date' do
        expect {
          create_sessions appointment
        }.to change{ Session.count }.by(7)
      end

      it_should_behave_like 'correctly created sessions'
    end

    context 'recurring monthly appointment' do
      let(:date_end) {   date_start + 6.months + 2.days }
      let(:appointment) {  FactoryGirl.create(:monthly_appointment,
          start_date: date_start,
          end_date:   date_end)
      }

      it 'creates a session on the same day each month between start and end date' do
        expect {
          create_sessions appointment
        }.to change{ appointment.sessions.count }.by(7)
      end

      it_should_behave_like 'correctly created sessions'
    end

    context 'single appointment' do
      let(:appointment) {  FactoryGirl.create(:appointment,
          start_date: date_start)
      }

      it 'creates a single session' do
        expect {
          create_sessions appointment
        }.to change{ appointment.sessions.count }.by(1)
      end

      it_should_behave_like 'correctly created sessions'
    end

    # stop-gap, arbitrary 100 dates limit
    context 'recurring daily appointment, no end date', focus: true do
      let(:appointment) {  FactoryGirl.create(:daily_appointment,
          start_date: date_start,
          end_date:   date_start + 1.year)
      }

      it 'raises an exception' do
        expect {
          create_sessions appointment
        }.to raise_error('Cannot create more than 100 sessions at time')
      end
    end
  end
end
