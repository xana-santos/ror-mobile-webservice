# require 'rails_helper'
#
# RSpec.describe Product, type: :request do
#
#   let(:product){FactoryGirl.create(:product)}
#   let(:product_category){FactoryGirl.create(:product_category)}
#
#   let(:serialized){ ProductSerializer.new(product).serializable_hash }
#   let(:deleted_serialized){ ProductSerializer.new(product, show_deleted: true).serializable_hash }
#
#   let(:new_product_params) do
#     {
#       "title" => "One Fabulous Product",
#       "description" => "Buy it before they run out!",
#       "product_id" => "HF-55442",
#       "unit_price" => 3000,
#       "unit_type" => "Some type",
#       "images" => [
#         {
#           "url" => "https://s3.amazonaws.com/example.jpg",
#           "position" => 1
#         }
#       ],
#       "categories" => [product_category.api_token],
#       "status" => "published",
#       "out_of_stock" => false,
#       "cost" => 3000
#     }
#   end
#
#   let(:update_product_params) do
#     {
#       "id" => product.api_token,
#       "title" => "One Really Fabulous Product"
#     }
#   end
#
#   let(:update_product_images_params) do
#     {
#       "id" => product.api_token,
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
#     xhr :post, "/v1/product", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new product without required parameters" do
#     xhr :post, "/v1/product", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["title", "product_id"]
#   end
#
#   it "successfully creates an product" do
#     xhr :post, "/v1/product", new_product_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an product" do
#     xhr :put, "/v1/product", update_product_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an product" do
#     xhr :get, "/v1/product", {id: product.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of products" do
#     product
#     xhr :get, "/v1/product/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"products" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted products if include_deleted is false" do
#     product
#     product.destroy!
#     xhr :get, "/v1/product/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["products"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted products if include_deleted is true" do
#     product
#     product.destroy!
#     xhr :get, "/v1/product/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["products"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/product/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     product
#     xhr :get, "/v1/product/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"products" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#   it "successfully removes an product" do
#     xhr :delete, "/v1/product", {id: product.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(product.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes products" do
#     xhr :delete, "/v1/product", {ids: [product.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(product.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active product" do
#     xhr :post, "/v1/product/restore", {id: product.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an product" do
#     product.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/product/restore", {id: product.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(product.reload.deleted_at).to eq nil
#   end
#
#   it "successfully sets image positions" do
#     xhr :put, "/v1/product", update_product_images_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#     product.images.each do |image|
#       param_image = update_product_images_params["images"].find{|i| i["url"] == image.url}
#       expect(image.position).to eq param_image["position"] if param_image
#     end
#   end
#
# end
