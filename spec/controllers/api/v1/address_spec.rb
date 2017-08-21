# require 'rails_helper'
#
# RSpec.describe Address, type: :request do
#
#   let(:client){FactoryGirl.create(:client)}
#   let(:address){FactoryGirl.create(:address, record: client)}
#   let(:serialized){ AddressSerializer.new(address, show_id: false).serializable_hash }
#   let(:deleted_serialized){ AddressSerializer.new(address, show_deleted: true).serializable_hash }
#
#   let(:new_address_params) do
#     {
#       "client_id"=> client.api_token,
#       "type"=> "billing",
#       "line_1"=> "123 Fake Street",
#       "suburb"=> "Pleasantville",
#       "state"=> "WA",
#       "postcode"=> "1234",
#       "main_address"=> true
#     }
#   end
#
#   let(:update_address_params) do
#     {
#       "id" => address.api_token,
#       "line_1" => "124 Fake Street",
#       "suburb" => "Pleasantown",
#       "state" => "WA",
#       "postcode" => "4321"
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/address", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new address without required parameters" do
#     xhr :post, "/v1/address", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["client_id", "line_1", "suburb", "state", "postcode", "main_address", "type"]
#   end
#
#   it "successfully creates an address" do
#     xhr :post, "/v1/address", new_address_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an address" do
#     xhr :put, "/v1/address", update_address_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an address" do
#     xhr :get, "/v1/address", {id: address.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of addresses" do
#     address
#     xhr :get, "/v1/address/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 2, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["addresses"]).to include serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/address/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     address
#     xhr :get, "/v1/address/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"addresses" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted addresses if include_deleted is false" do
#     address
#     address.destroy!
#     xhr :get, "/v1/address/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["addresses"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted addresses if include_deleted is true" do
#     address
#     address.destroy!
#     xhr :get, "/v1/address/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 2, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["addresses"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully removes an address" do
#     xhr :delete, "/v1/address", {id: address.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(address.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes addresses" do
#     xhr :delete, "/v1/address", {ids: [address.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(address.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active address" do
#     xhr :post, "/v1/address/restore", {id: address.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an address" do
#     address.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/address/restore", {id: address.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(address.reload.deleted_at).to eq nil
#   end
#
# end
