# require 'rails_helper'
#
# RSpec.describe Image, type: :request do
#
#   let(:product){FactoryGirl.create(:product)}
#   let(:image){FactoryGirl.create(:image, record: product)}
#
#   let(:serialized){ ImageSerializer.new(image).serializable_hash }
#   let(:deleted_serialized){ ImageSerializer.new(image, show_deleted: true).serializable_hash }
#
#   let(:new_image_params) do
#     {
#       "record_id"=> product.api_token,
#       "record_type" => "product",
#       "url" => "https://s3.amazonaws.com/example.jpg"
#     }
#   end
#
#   let(:update_image_params) do
#     {
#       "id" => image.api_token,
#       "url" => "https://s3.amazonaws.com/example2.jpg"
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/image", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new image without required parameters" do
#     xhr :post, "/v1/image", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["record_id", "record_type", "url"]
#   end
#
#   it "successfully creates an image" do
#     xhr :post, "/v1/image", new_image_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an image" do
#     xhr :put, "/v1/image", update_image_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an image" do
#     xhr :get, "/v1/image", {id: image.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of images" do
#     image
#     xhr :get, "/v1/image/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["images"]).to include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves only non-deleted images if include_deleted is false" do
#     image
#     image.destroy!
#     xhr :get, "/v1/image/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["images"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted images if include_deleted is true" do
#     image
#     image.destroy!
#     xhr :get, "/v1/image/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["images"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/image/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     image
#     xhr :get, "/v1/image/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"images" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully removes an image" do
#     xhr :delete, "/v1/image", {id: image.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(image.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes images" do
#     xhr :delete, "/v1/image", {ids: [image.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(image.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active image" do
#     xhr :post, "/v1/image/restore", {id: image.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an image" do
#     image.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/image/restore", {id: image.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(image.reload.deleted_at).to eq nil
#   end
#
# end
