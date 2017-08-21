# require 'rails_helper'
#
# RSpec.describe ProductCategory, type: :request do
#
#   let(:product_category){FactoryGirl.create(:product_category)}
#
#   let(:serialized){ ProductCategorySerializer.new(product_category).serializable_hash }
#   let(:deleted_serialized){ ProductCategorySerializer.new(product_category, show_deleted: true).serializable_hash }
#
#   let(:new_product_category_params) do
#     {
#       "category" => "Test Product Category",
#       "description" => "Test Product Category",
#     }
#   end
#
#   let(:update_product_category_params) do
#     {
#       "id" => product_category.api_token,
#       "description" => "Really cool test category 2"
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/product_category", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new product_category without required parameters" do
#     xhr :post, "/v1/product_category", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["category", "description"]
#   end
#
#   it "doesn't create a new product_category if category exists" do
#     params = {category: product_category.category, description: product_category.description}
#     xhr :post, "/v1/product_category", params.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["category"]
#     expect(json["errors"]["category"]).to include "already exists"
#   end
#
#   it "successfully creates an product_category" do
#     xhr :post, "/v1/product_category", new_product_category_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an product_category" do
#     xhr :put, "/v1/product_category", update_product_category_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an product_category" do
#     xhr :get, "/v1/product_category", {id: product_category.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of product_categories" do
#     product_category
#     xhr :get, "/v1/product_category/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"product_categories" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted product_categories if include_deleted is false" do
#     product_category
#     product_category.destroy!
#     xhr :get, "/v1/product_category/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["product_categories"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted product_categories if include_deleted is true" do
#     product_category
#     product_category.destroy!
#     xhr :get, "/v1/product_category/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["product_categories"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/product_category/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     product_category
#     xhr :get, "/v1/product_category/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"product_categories" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully removes a product category" do
#     xhr :delete, "/v1/product_category", {id: product_category.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(product_category.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes product categories" do
#     xhr :delete, "/v1/product_category", {ids: [product_category.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(product_category.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active product_category" do
#     xhr :post, "/v1/product_category/restore", {id: product_category.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an product_category" do
#     product_category.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/product_category/restore", {id: product_category.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(product_category.reload.deleted_at).to eq nil
#   end
#
# end
