# require 'rails_helper'
#
# RSpec.describe Client, type: :request do
#
#   let(:trainer){FactoryGirl.create(:trainer)}
#   let(:client){FactoryGirl.create(:client)}
#
#   let(:serialized){ ClientSerializer.new(client).serializable_hash }
#   let(:deleted_serialized){ ClientSerializer.new(client, show_deleted: true).serializable_hash }
#
#   let(:card_token){ Stripe::Token.create(card: { number: "4242424242424242", exp_month: 9, exp_year: 2019, cvc: "999"}) }
#   let(:pflo_card_token){ Stripe::Token.create(card: { number: "4242424242424242", exp_month: 9, exp_year: 2019, cvc: "999"}) }
#
#   let(:new_client_params) do
#     {
#       "trainer_id" => trainer.api_token,
#       "first_name" => "Example",
#       "last_name" => "User",
#       "email" => "demo@client.com",
#       "mobile" => "0400000000",
#       "office" => "12345678",
#       "phone" => "12345678",
#       "image" => {
#         "url" => "https://s3.amazonaws.com/example.jpg"
#       },
#       "card_token" => card_token,
#       "pflo_card_token" => pflo_card_token,
#       "client_details" => {
#         "start_date" => "2015-12-25",
#         "supplement_only" => true,
#         "session_duration" => 45,
#         "session_rate" => 1000
#       },
#       "addresses" => [
#         {
#           "type" => "billing",
#           "line_1" => "123 Fake Street",
#           "suburb" => "Pleasantville",
#           "state" => "WA",
#           "postcode" => "1234",
#           "main_address" => true
#         }
#       ]
#     }
#   end
#
#   let(:update_client_params) do
#     {
#     "id" => client.api_token,
#     "mobile" => "+61400000000",
#     "mobile_preferred" => true,
#     "last_name" => "Shoes",
#     "addresses" => [
#       {"main_address" => true, "state" => "ACT", "suburb" => "qwe", "line_1" => "qwe", "postcode" => "123", "type" => "shipping" },
#       {"main_address" => false, "state" => "ACT", "suburb" => "qwe", "line_1" => "qwe", "postcode" => "123", "type" => "billing"}
#     ],
#     "birthdate" => "1990-01-06",
#     "image" => {"url" => "images\/3FD39C0B-8081-4295-AF78-486A74B90A45.jpg"},
#     "client_details"=> {"session_duration" => 45, "session_rate" => 4500, "supplement_only"=> false, "start_date"=> "2015-11-25"},
#     "first_name"=> "Nice"}
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/client", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new client without required parameters" do
#     xhr :post, "/v1/client", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["first_name", "last_name", "email", "trainer_id"]
#   end
#
#   it "successfully creates a client" do
#     xhr :post, "/v1/client", new_client_params.to_json, json_headers
#     puts response.body
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates a client" do
#     client.update_columns(stripe_id: nil)
#     xhr :put, "/v1/client", update_client_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves a client" do
#     xhr :get, "/v1/client", {id: client.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of clients" do
#     client
#     xhr :get, "/v1/client/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"clients" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted clients if include_deleted is false" do
#     client
#     client.destroy!
#     xhr :get, "/v1/client/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["clients"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted clients if include_deleted is true" do
#     client
#     client.destroy!
#     xhr :get, "/v1/client/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["clients"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/client/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     client
#     xhr :get, "/v1/client/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"clients" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully sets retrieves list for a trainer" do
#     xhr :get, "/v1/client/list", {trainer_id: client.trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"clients" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to include expectation
#   end
#
#   it "successfully sets returns no list for a trainer without clients" do
#     xhr :get, "/v1/client/list", {trainer_id: trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"clients" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully removes a client" do
#     xhr :delete, "/v1/client", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(client.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes clients" do
#     xhr :delete, "/v1/client", {ids: [client.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(client.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active client" do
#     xhr :post, "/v1/client/restore", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores a client" do
#     client.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/client/restore", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(client.reload.deleted_at).to eq nil
#   end
#
#   it "successfully deactivates a client" do
#     xhr :post, "/v1/client/deactivate", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deactivated"
#     expect(client.reload.active).to_not eq true
#   end
#
#   it "wont deactivate an inactive client" do
#     client.update_column(:active, false)
#     xhr :post, "/v1/client/deactivate", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully activates a client" do
#     client.update_column(:active, false)
#     xhr :post, "/v1/client/activate", {id: client.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "activated"
#     expect(client.reload.deleted_at).to eq nil
#   end
#
#   it "doesn't authorize a client with wrong credentials" do
#     xhr :post, "/v1/client/authenticate", {email: client.email, password: "wrong-password"}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "Invalid email/password"
#   end
#
#   it "authorizes a client with correct credentials" do
#     xhr :post, "/v1/client/authenticate", {email: client.email, password: "password"}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to include "authenticated"
#   end
#
# end
