# require 'rails_helper'
#
# RSpec.describe Trainer, type: :request do
#
#   let(:gym){FactoryGirl.create(:gym)}
#   let(:trainer){FactoryGirl.create(:trainer)}
#
#   let(:gym_location){FactoryGirl.create(:gym_location)}
#
#   let(:serialized){ TrainerSerializer.new(trainer).serializable_hash }
#   let(:deleted_serialized){ TrainerSerializer.new(trainer, show_deleted: true).serializable_hash }
#
#   let(:new_trainer_params) do
#     {
#       "first_name" => "Example",
#       "last_name" => "User",
#       "email" => "demo@trainer.com",
#       "password" => "password",
#       "mobile" => "0400000000",
#       "office" => "12345678",
#       "phone" => "12345678",
#       "abn" => "12345678910",
#       "birthdate" => "1990-22-12",
#       "address" => {
#         "line_1" => "123 Fake Street",
#         "suburb" => "Pleasantville",
#         "state" => "WA",
#         "postcode" => "1234"
#       },
#       "image" => {
#         "url" => "http://example.com/test.jpg"
#       },
#       "gym_location_id" => gym_location.api_token
#     }
#   end
#
#   let(:update_trainer_params) do
#     {
#       "id" => trainer.api_token,
#       "mobile" => "+61458880404",
#       "gym_location_id" => gym_location.api_token,
#       "first_name" => "Stripe",
#       "last_name" => "Test",
#       "image" => {
#         "url" => "images\/DC22159C-D383-4275-AA38-16AA30EA4C95.jpg"
#       },
#       "identity_image" => {
#         "url" => "images\/DC22159C-D383-4275-AA38-16AA30EA4C90.jpg"
#       },
#       "targets" => {
#         "earning" => 120000,
#         "supplement_sales" => 60000,
#         "work_hours" => 40,
#         "date" => "2015-12-25",
#         "holidays" => 12
#       },
#       "address" => {
#         "line_1" => "123 Fake Street",
#         "suburb" => "Pleasantville",
#         "state" => "WA",
#         "postcode" => "1234"
#       },
#       "email" => "trainer3@test.com",
#       "abn" => "53004085616"
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/trainer", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new trainer without required parameters" do
#     xhr :post, "/v1/trainer", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["email", "first_name", "gym_location_id", "last_name", "password"]
#   end
#
#   it "successfully creates a trainer" do
#     xhr :post, "/v1/trainer", new_trainer_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates a trainer" do
#     trainer.update_columns(stripe_id: nil)
#     xhr :put, "/v1/trainer", update_trainer_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully updates an unverified trainer" do
#     trainer.trainer_identification.update_columns(status: "unverified")
#     trainer.update_columns(stripe_id: nil)
#     xhr :put, "/v1/trainer", update_trainer_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves a trainer" do
#     xhr :get, "/v1/trainer", {id: trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of trainers" do
#     trainer
#     xhr :get, "/v1/trainer/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"trainers" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted trainers if include_deleted is false" do
#     trainer
#     trainer.destroy!
#     xhr :get, "/v1/trainer/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["trainers"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted trainers if include_deleted is true" do
#     trainer
#     trainer.destroy!
#     xhr :get, "/v1/trainer/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["trainers"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/trainer/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     trainer
#     xhr :get, "/v1/trainer/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"trainers" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully removes a trainer" do
#     xhr :delete, "/v1/trainer", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(trainer.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes trainers" do
#     xhr :delete, "/v1/trainer", {ids: [trainer.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(trainer.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active trainer" do
#     xhr :post, "/v1/trainer/restore", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores a trainer" do
#     trainer.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/trainer/restore", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(trainer.reload.deleted_at).to eq nil
#   end
#
#   it "doesn't authorize a trainer with wrong credentials" do
#     xhr :post, "/v1/trainer/authenticate", {email: trainer.email, password: "wrong-password"}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "Invalid email/password"
#   end
#
#   it "authorizes a trainer with correct credentials" do
#     xhr :post, "/v1/trainer/authenticate", {email: trainer.email, password: "password"}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to include "authenticated"
#   end
#
#   it "successfully deactivates a trainer" do
#     xhr :post, "/v1/trainer/deactivate", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deactivated"
#     expect(trainer.reload.active).to_not eq true
#   end
#
#   it "wont deactivate an inactive trainer" do
#     trainer.update_column(:active, false)
#     xhr :post, "/v1/trainer/deactivate", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully activates a trainer" do
#     trainer.update_column(:active, false)
#     xhr :post, "/v1/trainer/activate", {id: trainer.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "activated"
#     expect(trainer.reload.deleted_at).to eq nil
#   end
#
# end
