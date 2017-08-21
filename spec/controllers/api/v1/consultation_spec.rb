# require 'rails_helper'
#
# RSpec.describe Consultation, type: :request do
#
#   let(:client){FactoryGirl.create(:client)}
#   let(:consultation){FactoryGirl.create(:consultation)}
#
#   let(:serialized){ ConsultationSerializer.new(consultation).serializable_hash }
#   let(:deleted_serialized){ ConsultationSerializer.new(consultation, show_deleted: true).serializable_hash }
#
#   let(:new_consultation_params) do
#     {
#       "client_id"=> client.api_token,
#       "chest" => 30.0,
#       "hips" => 30.0,
#       "weight" => 30.0,
#       "waist" => 30.0,
#       "lean_body_weight" => 30.0,
#       "body_fat_weight" => 30.0,
#       "measurement" => 130.0,
#       "left_arm" => 10.0,
#       "right_arm" => 8.0,
#       "glutes" => 30.0,
#       "left_quads" => 30.0,
#       "right_quads" => 30.0,
#       "left_calf" => 20.0,
#       "right_calf" => 20.0,
#       "total_measurement" => 30.0,
#       "fat_percentage" => 20.0,
#       "consultation_date" => "2015-08-08",
#       "consultation_time" => "15:49",
#       "images" => [
#         {
#           "url" => "https://s3.amazonaws.com/example.jpg",
#           "position" => 1
#         }
#       ]
#     }
#   end
#
#   let(:update_consultation_params) do
#     {
#       "id" => consultation.api_token,
#       "chest" => 30.0,
#       "hips" => 30.0
#     }
#   end
#
#   let(:update_consultation_images_params) do
#     {
#       "id" => consultation.api_token,
#       "images" => [
#         {
#           "url" => "https://s3.amazonaws.com/example2.jpg",
#           "position" => 1
#         },
#         {
#           "url" => "https://s3.amazonaws.com/example.jpg",
#           "position" => 0
#         },
#         {
#           "url" => "https://s3.amazonaws.com/example3.jpg",
#           "position" => 2
#         }
#       ]
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/consultation", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new consultation without required parameters" do
#     xhr :post, "/v1/consultation", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["client_id", "consultation_date", "consultation_time"]
#   end
#
#   it "successfully creates an consultation" do
#     xhr :post, "/v1/consultation", new_consultation_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an consultation" do
#     xhr :put, "/v1/consultation", update_consultation_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an consultation" do
#     xhr :get, "/v1/consultation", {id: consultation.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of consultations" do
#     consultation.save
#     xhr :get, "/v1/consultation/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"consultations" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted consultations if include_deleted is false" do
#     consultation
#     consultation.destroy!
#     xhr :get, "/v1/consultation/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["consultations"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted consultations if include_deleted is true" do
#     consultation
#     consultation.destroy!
#     xhr :get, "/v1/consultation/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["consultations"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/consultation/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     consultation
#     xhr :get, "/v1/consultation/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"consultations" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully sets retrieves list for a client" do
#     xhr :get, "/v1/consultation/list", {client_id: consultation.client.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"consultations" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to include expectation
#   end
#
#   it "successfully sets retrieves list for a trainer" do
#     xhr :get, "/v1/consultation/list", {trainer_id: consultation.trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"consultations" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to include expectation
#   end
#
#   it "successfully sets returns no list for a client without consultations" do
#     xhr :get, "/v1/consultation/list", {client_id: client.api_token}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"consultations" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully removes an consultation" do
#     xhr :delete, "/v1/consultation", {id: consultation.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(consultation.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes consultations" do
#     xhr :delete, "/v1/consultation", {ids: [consultation.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(consultation.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active consultation" do
#     xhr :post, "/v1/consultation/restore", {id: consultation.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an consultation" do
#     consultation.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/consultation/restore", {id: consultation.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(consultation.reload.deleted_at).to eq nil
#   end
#
#   it "successfully sets image positions" do
#     xhr :put, "/v1/consultation", update_consultation_images_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#     consultation.images.each do |image|
#       param_image = update_consultation_images_params["images"].find{|i| i["url"] == image.url}
#       expect(image.position).to eq param_image["position"] if param_image
#     end
#   end
#
# end
