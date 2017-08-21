require 'rails_helper'

RSpec.describe Appointment, type: :request do
  let(:client){FactoryGirl.create(:client)}
  # let(:client2){FactoryGirl.create(:client)}
  #
  let(:trainer){FactoryGirl.create(:trainer)}

  let(:appointment){FactoryGirl.create(:appointment)}
  let(:session){ FactoryGirl.create(:session, appointment: appointment) }

  let(:serialized){ AppointmentSerializer.new(appointment).serializable_hash }
  let(:deleted_serialized){ AppointmentSerializer.new(appointment, show_deleted: true).serializable_hash }

  let(:from_time){ (Time.parse("#{appointment.start_time} UTC") - 1.minute).strftime("%H:%M") }
  let(:to_time){ (Time.parse("#{appointment.end_time} UTC") + 1.minute).strftime("%H:%M") }

  let(:single_appointment_param) do
    {
      "trainer_id" => trainer.api_token,
      "clients" => [client.api_token],
      "event_type"=>"appointment",
      "event_note"=>"Some event note",
      "start_date"=>"2017-03-01",
      "start_time"=>"15:50",
      "end_date"=>"2015-07-01",
      "end_time"=>"16:50",
      "all_day_event"=>false,
      "session_rate"=>9999,
      "repeat_after"=>"never"
    }
  end

  let(:recurring_appointment_param) do
    {
      "trainer_id" => trainer.api_token,
      "clients" => [client.api_token],
      "event_type"=>"appointment",
      "event_note"=>"Some event note",
      "start_date"=>"2017-03-01",
      "start_time"=>"15:50",
      "end_date"=>"3000-01-01",
      # "end_time"=>"16:50",
      "end_time"=>"00:00",
      "all_day_event"=>false,
      "session_rate"=>9999,
      "repeat_after"=>"day"
    }
  end

  let(:update_appointment_params) do
    {
      "id" => appointment.api_token,
      "start_date"=>"2015-08-08",
      "start_time"=>"16:49",
      "end_date"=>"2015-08-08",
      "end_time"=>"17:49"
    }
  end
  #
  # let(:add_client_params) do
  #   {
  #     "id" => appointment.api_token,
  #     "clients" => [client.api_token, client2.api_token]
  #   }
  # end
  #
  it "rejects unauthorised token" do
    xhr :post, "/v1/appointment", {}, {}
    expect(response.status).to eq 403
    expect(response.body).to include "Unauthorized."
  end

  it "doesn't create a new appointment without required parameters" do
    xhr :post, "/v1/appointment", {}, json_headers
    expect(response.status).to eq 400
    expect(json["errors"].keys).to match_array ["trainer_id", "event_type"]
  end

  it "successfully creates a single appointment" do
    xhr :post, "/v1/appointment", single_appointment_param.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully creates a daily recurring appointment" do
    xhr :post, "/v1/appointment", recurring_appointment_param.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully creates a weekly recurring appointment" do
    recurring_appointment_param[:repeat_after] = "week"
    xhr :post, "/v1/appointment", recurring_appointment_param.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully creates a fortnightly recurring appointment" do
    recurring_appointment_param[:repeat_after] = "fortnight"
    xhr :post, "/v1/appointment", recurring_appointment_param.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully creates a monthly recurring appointment" do
    recurring_appointment_param[:repeat_after] = "month"
    xhr :post, "/v1/appointment", recurring_appointment_param.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["id", "status"]
    expect(json["status"]).to eq "created"
  end

  it "successfully updates an appointment" do
    xhr :put, "/v1/appointment", update_appointment_params.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status"]
    expect(json["status"]).to eq "updated"
  end

  # it "successfully adds another client" do
  #   xhr :put, "/v1/appointment", add_client_params.to_json, json_headers
  #   expect(response.status).to eq 200
  #   expect(json.keys).to match_array ["status"]
  #   expect(json["status"]).to eq "updated"
  #   expect(appointment.reload.appointment_clients.size).to eq 2
  # end
  #
  it "successfully retrieves an appointment" do
    session
    xhr :get, "/v1/appointment", {id: appointment.api_token}, json_headers
    expect(response.status).to eq 200
    expect(json).to match serialized.deep_stringify_keys
  end

  it "successfully retrieves a list of appointments" do
    appointment
    xhr :get, "/v1/appointment/list", {}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json).to match expectation
  end

  it "successfully sets list offset and limit" do
    xhr :get, "/v1/appointment/list", {limit: 10, offset: 3}, json_headers
    expect(response.status).to eq 200
    meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10, "remove_limit"=>"false"}}
    expect(json).to include meta
  end

  it "successfully retrieves only non-deleted appointments if include_deleted is false" do
    appointment
    appointment.destroy!
    xhr :get, "/v1/appointment/list", {}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25}
    expect(json["meta"]).to include meta
    expect(json["appointments"]).to_not include serialized.deep_stringify_keys
  end

  it "successfully retrieves deleted appointments if include_deleted is true" do
    appointment
    appointment.destroy!
    xhr :get, "/v1/appointment/list", {include_deleted: true}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25}
    expect(json["meta"]).to include meta
    expect(json["appointments"]).to include deleted_serialized.deep_stringify_keys
  end

  it "returns no records if their last update was before timestamp" do
    appointment
    xhr :get, "/v1/appointment/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [], "meta" => meta}
    expect(json).to match expectation
  end

  it "successfully sets retrieves list for a client" do
    xhr :get, "/v1/appointment/list", {client_id: appointment.appointment_clients.first.api_token}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully sets retrieves list for a trainer" do
    xhr :get, "/v1/appointment/list", {trainer_id: appointment.trainer.api_token}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully returns no list for a trainer without appointments" do
    xhr :get, "/v1/appointment/list", {trainer_id: trainer.api_token}, json_headers
    expect(response.status).to eq 200
    expectation = {"appointments" => []}
    expect(json).to include expectation
  end

  it "successfully returns no list for a client without appointments" do
    xhr :get, "/v1/appointment/list", {client_id: client.api_token}, json_headers
    expect(response.status).to eq 200
    expectation = {"appointments" => []}
    expect(json).to include expectation
  end

  it "successfully retrieves list if datetime after or on start" do
    xhr :get, "/v1/appointment/list", {start: {date: Date.today.strftime("%Y-%m-%d"), time: from_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully retrieves list if datetime before or on end" do
    appointment
    xhr :get, "/v1/appointment/list", {end: {date: (Date.today + 1.week).strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 1, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [serialized.deep_stringify_keys], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully returns no list if no appointments starting before datetime" do
    appointment
    xhr :get, "/v1/appointment/list", {start: {date: Date.tomorrow.strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully returns no list if no appointments ending before datetime" do
    appointment
    xhr :get, "/v1/appointment/list", {end: {date: Date.yesterday.strftime("%Y-%m-%d"), time: to_time}}, json_headers
    expect(response.status).to eq 200
    meta = {"total" => 0, "offset" => 0, "limit" => 25, "remove_limit"=>"false"}
    expectation = {"appointments" => [], "meta" => meta}
    expect(json).to include expectation
  end

  it "successfully removes an appointment" do
    xhr :delete, "/v1/appointment", {id: appointment.api_token}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status"]
    expect(json["status"]).to eq "deleted"
    expect(appointment.reload.deleted_at).to_not eq nil
  end

  it "successfully removes appointments" do
    xhr :delete, "/v1/appointment", {ids: [appointment.api_token]}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status"]
    expect(json["status"]).to eq "deleted"
    expect(appointment.reload.deleted_at).to_not eq nil
  end

  it "wont restore an active appointment" do
    xhr :post, "/v1/appointment/restore", {id: appointment.api_token}.to_json, json_headers
    expect(response.status).to eq 400
    expect(json.keys).to match_array ["errors"]
    expect(json["errors"]).to include "does not exist"
  end

  it "successfully restores an appointment" do
    appointment.update_column(:deleted_at, Time.now)
    xhr :post, "/v1/appointment/restore", {id: appointment.api_token}.to_json, json_headers
    expect(response.status).to eq 200
    expect(json.keys).to match_array ["status"]
    expect(json["status"]).to eq "restored"
    expect(appointment.reload.deleted_at).to eq nil
  end

end
