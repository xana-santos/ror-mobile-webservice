# require 'rails_helper'
#
# RSpec.describe GymLocation, type: :request do
#
#   let(:trainer){FactoryGirl.create(:trainer)}
#
#   let(:gym){FactoryGirl.create(:gym)}
#   let(:gym_location){FactoryGirl.create(:gym_location)}
#
#   let(:serialized){ GymLocationSerializer.new(gym_location).serializable_hash }
#   let(:deleted_serialized){ GymLocationSerializer.new(gym_location, show_deleted: true).serializable_hash }
#
#   let(:new_gym_location_params) do
#     {
#       "gym_id" => gym.api_token,
#       "name" => "Queen St",
#       "phone_number" => "12345678",
#       "address" => {
#         "line_1" => "123 Fake Street",
#         "suburb" => "Pleasantville",
#         "state" => "WA",
#         "postcode" => "1234"
#       }
#     }
#   end
#
#   let(:update_gym_location_params) do
#     {
#       "id" => gym_location.api_token,
#       "name" => "Queen St 2"
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/gym_location", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new gym_location without required parameters" do
#     xhr :post, "/v1/gym_location", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["address", "gym_id", "name"]
#   end
#
#   it "successfully creates an gym_location" do
#     xhr :post, "/v1/gym_location", new_gym_location_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an gym_location" do
#     xhr :put, "/v1/gym_location", update_gym_location_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an gym_location" do
#     xhr :get, "/v1/gym_location", {id: gym_location.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of gym_locations" do
#     gym_location
#     xhr :get, "/v1/gym_location/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"gym_locations" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted gym_locations if include_deleted is false" do
#     gym_location
#     gym_location.destroy!
#     xhr :get, "/v1/gym_location/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["gym_locations"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted gym_locations if include_deleted is true" do
#     gym_location
#     gym_location.destroy!
#     xhr :get, "/v1/gym_location/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["gym_locations"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/gym_location/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "successfully retrieves list for a gym" do
#     xhr :get, "/v1/gym_location/list", {gym_id: gym_location.gym.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"gym_locations" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["gym_locations"]).to include expectation["gym_locations"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a gym without gym locations" do
#     xhr :get, "/v1/gym_location/list", {gym_id: gym.api_token + "1"}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"gym_locations" => []}
#     expect(json).to include expectation
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     gym_location
#     xhr :get, "/v1/gym_location/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"gym_locations" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully removes an gym_location" do
#     xhr :delete, "/v1/gym_location", {id: gym_location.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(gym_location.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes gym_locations" do
#     xhr :delete, "/v1/gym_location", {ids: [gym_location.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(gym_location.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active gym_location" do
#     xhr :post, "/v1/gym_location/restore", {id: gym_location.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an gym_location" do
#     gym_location.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/gym_location/restore", {id: gym_location.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(gym_location.reload.deleted_at).to eq nil
#   end
#
# end
