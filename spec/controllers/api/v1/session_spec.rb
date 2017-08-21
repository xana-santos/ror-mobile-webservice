require 'rails_helper'

RSpec.describe Session, type: :request do

  # let(:client){ FactoryGirl.create(:client) }
  # let(:trainer){ FactoryGirl.create(:trainer) }
  let(:appointment){ FactoryGirl.create(:appointment) }

  let(:session){FactoryGirl.create(:session)}

  let(:serialized){ SessionSerializer.new(session).serializable_hash }

  let(:from_time){ (Time.parse("#{session.time} UTC") - 1.minute).strftime("%H:%M") }
  let(:to_time){ (Time.parse("#{session.time} UTC") + 1.minute).strftime("%H:%M") }

  it "rejects unauthorised token" do
    xhr :post, "/v1/session", {}, {}
    expect(response.status).to eq 403
    expect(response.body).to include "Unauthorized."
  end

  it "successfully removes a session" do
    session
    xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status", "timestamp"]
    expect(json["status"]).to eq "cancelled"
  end

  it "successfully creates a session" do
    xhr :post, "/v1/session", {appointment_id: appointment.api_token, date: Date.today.strftime("%Y-%m-%d"), status: "cancelled"}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully retrieves an session" do
    xhr :get, "/v1/session", {id: session.api_token}, json_headers
    expect(response.status).to eq 200
    expect(json).to match serialized.deep_stringify_keys
  end

  it "successfully retrieves a list of sessions" do
    session
    xhr :get, "/v1/session/list", {}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully sets list offset and limit" do
    xhr :get, "/v1/session/list", {limit: 10, offset: 3}, json_headers
    expect(response.status).to eq 200
    meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
    expect(json).to include meta
  end

  it "successfully retrieves list for a client" do
    xhr :get, "/v1/session/list", {client_id: session.clients.first.api_token}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully returns no list for a client without sessions" do
    xhr :get, "/v1/session/list", {client_id: client.api_token}, json_headers
    expect(response.status).to eq 200
    expectation = {"sessions" => []}
    expect(json).to include expectation
  end

  it "successfully retrieves list for a trainer" do
    xhr :get, "/v1/session/list", {trainer_id: session.trainer.api_token}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully returns no list for a trainer without sessions" do
    xhr :get, "/v1/session/list", {trainer_id: trainer.api_token}, json_headers
    expect(response.status).to eq 200
    expectation = {"sessions" => []}
    expect(json).to include expectation
  end

  it "successfully retrieves list for a appointment" do
    xhr :get, "/v1/session/list", {appointment_id: session.appointment.api_token}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully returns no list for an appointment without sessions" do
    xhr :get, "/v1/session/list", {appointment_id: appointment.api_token}, json_headers
    expect(response.status).to eq 200
    expectation = {"sessions" => []}
    expect(json).to include expectation
  end

  it "successfully retrieves list if datetime after or on start" do
    xhr :get, "/v1/session/list", {start: {date: Date.today.strftime("%Y-%m-%d"), time: from_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully retrieves list if datetime before or on end" do
    xhr :get, "/v1/session/list", {end: {date: session.date.strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json["sessions"]).to include expectation["sessions"][0]
    expect(json["meta"]).to match expectation["meta"]
  end

  it "successfully returns no list if no sessions before date" do
    xhr :get, "/v1/session/list", {start: {date: Date.tomorrow.strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully returns no list if no sessions after date" do
    xhr :get, "/v1/session/list", {end: {date: Date.yesterday.strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [], "meta" => meta}
    expect(json).to include expectation
  end

  it "returns no records if their last update was before timestamp" do
    session
    xhr :get, "/v1/session/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25}
    expectation = {"sessions" => [], "meta" => meta}
    expect(json).to match expectation
  end

  it "succesfully marks session as declined for an invalid client" do
    session
    client = session.clients.first
    xhr :post, "/v1/session/mark_attendance", {id: session.api_token, clients: [{id: client.api_token, attended: true}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["clients"]
    expect(json["clients"][0].keys).to match_array ["client_session", "id", "invoice", "status"]
    expect(json["clients"][0]["invoice"].keys).to include *["paid", "payment_details"]
    expect(json["clients"][0]["invoice"]["paid"]).to eq false
  end

  it "succesfully marks session attended for a client" do
    session
    client = session.clients.first
    xhr :post, "/v1/session/mark_attendance", {id: session.api_token, clients: [{id: client.api_token, attended: true}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["clients"]
    expect(json["clients"][0].keys).to match_array ["client_session", "id", "invoice", "status"]
    expect(json["clients"][0]["invoice"].keys).to include *["paid", "payment_details"]
    expect(json["clients"][0]["invoice"]["paid"]).to eq true
  end

  it "succesfully marks session unattended for a client" do
    session
    client = session.clients.first
    xhr :post, "/v1/session/mark_attendance", {id: session.api_token, clients: [{id: client.api_token, attended: false, charge_percent: 0}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["clients"]
    expect(json["clients"][0].keys).to match_array ["client_session", "id", "invoice", "status"]
    expect(json["clients"][0]["invoice"].keys).to include *["paid", "payment_details"]
    expect(json["clients"][0]["invoice"]["paid"]).to eq true
  end

  it "returns error if client not set up for stripe" do
    session
    client = session.clients.first
    client.update_columns(stripe_id: nil)
    xhr :post, "/v1/session/mark_attendance", {id: session.api_token, clients: [{id: client.api_token, attended: true}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json["clients"][0]["invoice"]["payment_details"]).to include "Error"
  end

  it "handles a free appointment charge" do
    session
    client = session.clients.first
    xhr :post, "/v1/session/mark_attendance", {id: session.api_token, clients: [{id: client.api_token, attended: true, charge_percent: 0}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json["clients"][0]["invoice"]["paid"]).to eq true
  end


  it "succesfully resends confirmation for a client" do
    session.client_sessions.first.update_columns(status: "invited")
    client = session.clients.first
    xhr :post, "/v1/session/resend_confirmation", {id: session.api_token, clients: [{id: client.api_token}]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status"]
    expect(json["status"]).to eq "resent"
  end


  #
  # it "removes a cancelled session" do
  #   session
  #   session_count = Session.all.count
  #   xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #   expect(Session.count).to eq(session_count - 1)
  # end

  # context "Recurring sessions" do
  #   it "delete appointment when no more sessions left" do
  #     appointment.sessions.find_or_create_by(date: session.date)
  #     appointment_session = appointment.sessions.first
  #     number_of_appointments = Appointment.count
  #
  #     xhr :delete, "/v1/session/cancel", {id: appointment_session.api_token}.to_json, json_headers
  #
  #     expect(Appointment.count).to eq(number_of_appointments-1)
  #   end
  #
  #   it "changes appointment start date if first session is removed" do
  #     daily_appointment = FactoryGirl.create(:daily_appointment)
  #     param_formatted_start_date = daily_appointment.start_date.to_s
  #     param_formatted_end_date = daily_appointment.end_date.to_s
  #     daily_appointment.create_sessions(param_formatted_start_date, param_formatted_end_date)
  #     session = daily_appointment.sessions.first
  #
  #     xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #     daily_appointment.reload
  #     expect(daily_appointment.start_date).to_not eq(session.date)
  #     expect(daily_appointment.start_date).to eq(daily_appointment.sessions.first.date)
  #   end
  #
  #   it "changes appointment start date if first session is removed with more then 2 sessions" do
  #     daily_appointment = FactoryGirl.create(:daily_appointment, end_date: Date.today + 2.days)
  #     param_formatted_start_date = daily_appointment.start_date.to_s
  #     param_formatted_end_date = daily_appointment.end_date.to_s
  #     daily_appointment.create_sessions(param_formatted_start_date, param_formatted_end_date)
  #     session = daily_appointment.sessions.first
  #
  #     xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #     daily_appointment.reload
  #     expect(daily_appointment.start_date).to_not eq(session.date)
  #     expect(daily_appointment.start_date).to eq(daily_appointment.sessions.first.date)
  #   end
  #
  #   it "changes appointment end date if last session is removed" do
  #     daily_appointment = FactoryGirl.create(:daily_appointment)
  #     param_formatted_start_date = daily_appointment.start_date.to_s
  #     param_formatted_end_date = daily_appointment.end_date.to_s
  #     daily_appointment.create_sessions(param_formatted_start_date, param_formatted_end_date)
  #     session = daily_appointment.sessions.last
  #
  #     xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #     daily_appointment.reload
  #     expect(daily_appointment.end_date).to_not eq(session.date)
  #     expect(daily_appointment.end_date).to eq(daily_appointment.sessions.last.date)
  #   end
  #
  #   it "changes appointment end date if last session is removed with more then 2 sessions" do
  #     daily_appointment = FactoryGirl.create(:daily_appointment, end_date: Date.today + 2.days)
  #     param_formatted_start_date = daily_appointment.start_date.to_s
  #     param_formatted_end_date = daily_appointment.end_date.to_s
  #     daily_appointment.create_sessions(param_formatted_start_date, param_formatted_end_date)
  #     session = daily_appointment.sessions.last
  #
  #     xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #     daily_appointment.reload
  #     expect(daily_appointment.end_date).to_not eq(session.date)
  #     expect(daily_appointment.end_date).to eq(daily_appointment.sessions.last.date)
  #   end
  #
  #   it "doesn't change appointment date if middle session is removed" do
  #     daily_appointment = FactoryGirl.create(:daily_appointment, end_date: Date.today + 2.days)
  #     start_date = daily_appointment.start_date
  #     end_date = daily_appointment.end_date
  #     param_formatted_start_date = start_date.to_s
  #     param_formatted_end_date = end_date.to_s
  #     daily_appointment.create_sessions(param_formatted_start_date, param_formatted_end_date)
  #     session = daily_appointment.sessions[1] # middle session
  #
  #     xhr :delete, "/v1/session/cancel", {id: session.api_token}.to_json, json_headers
  #     daily_appointment.reload
  #
  #     expect(daily_appointment.start_date).to eq(start_date)
  #     expect(daily_appointment.end_date).to eq(end_date)
  #   end
  # end
  #
end
