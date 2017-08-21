# require 'rails_helper'
#
# RSpec.describe Gym, type: :request do
#
#   let(:trainer){FactoryGirl.create(:trainer)}
#
#   let(:gym){FactoryGirl.create(:gym)}
#   let(:gym_location){FactoryGirl.create(:gym_location, gym: gym)}
#
#   let(:serialized){ GymSerializer.new(gym).serializable_hash }
#   let(:deleted_serialized){ GymSerializer.new(gym, show_deleted: true).serializable_hash }
#
#   let(:new_gym_params) do
#     {
#       "name" => "Example Gym",
#       "locations" => [{
#         "name" => "Queen St",
#         "phone_number" => "12345678",
#         "address" => {
#           "line_1" => "123 Fake Street",
#           "suburb" => "Pleasantville",
#           "state" => "WA",
#           "postcode" => "1234"
#         }
#       }]
#     }
#   end
#
#   let(:update_gym_params) do
#     {
#       "id" => gym.api_token,
#       "name" => "Example Gym 2",
#       "locations" => [{
#         "name" => "Queen St",
#         "phone_number" => "12345678",
#         "address" => {
#           "line_1" => "123 Fake Street",
#           "suburb" => "Pleasantville",
#           "state" => "WA",
#           "postcode" => "1234"
#         }
#       }]
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/gym", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new gym without required parameters" do
#     xhr :post, "/v1/gym", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["locations", "name"]
#   end
#
#   it "successfully creates an gym" do
#     xhr :post, "/v1/gym", new_gym_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an gym" do
#     xhr :put, "/v1/gym", update_gym_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an gym" do
#     xhr :get, "/v1/gym", {id: gym.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of gyms" do
#     gym
#     xhr :get, "/v1/gym/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"gyms" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted gyms if include_deleted is false" do
#     gym
#     gym.destroy!
#     xhr :get, "/v1/gym/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["gyms"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted gyms if include_deleted is true" do
#     gym
#     gym.destroy!
#     xhr :get, "/v1/gym/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["gyms"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/gym/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     gym
#     xhr :get, "/v1/gym/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"gyms" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully removes an gym" do
#     xhr :delete, "/v1/gym", {id: gym.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(gym.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes gyms" do
#     xhr :delete, "/v1/gym", {ids: [gym.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(gym.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active gym" do
#     xhr :post, "/v1/gym/restore", {id: gym.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an gym" do
#     gym.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/gym/restore", {id: gym.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(gym.reload.deleted_at).to eq nil
#   end
#
# end
