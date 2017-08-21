# require 'rails_helper'
#
# RSpec.describe InvoiceItem, type: :request do
#
#   let(:invoice_item){FactoryGirl.create(:invoice_item)}
#   let(:serialized){ InvoiceItemSerializer.new(invoice_item).serializable_hash }
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/invoice_item", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "successfully retrieves an invoice_item" do
#     xhr :get, "/v1/invoice_item", {id: invoice_item.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of invoice_items" do
#     invoice_item
#     xhr :get, "/v1/invoice_item/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoice_items" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/invoice_item/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     invoice_item
#     xhr :get, "/v1/invoice_item/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"invoice_items" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves list for a record_type" do
#     invoice_item
#     xhr :get, "/v1/invoice_item/list", {record_type: "client_session"}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoice_items" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["invoice_items"]).to include expectation["invoice_items"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a type with no items" do
#     xhr :get, "/v1/invoice_item/list", {record_type: "product"}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"invoice_items" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully retrieves list for a record_id" do
#     xhr :get, "/v1/invoice_item/list", {record_id: invoice_item.record_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoice_items" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["invoice_items"]).to include expectation["invoice_items"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a record id without invoice_items" do
#     xhr :get, "/v1/invoice_item/list", {record_id: "0"}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"invoice_items" => []}
#     expect(json).to include expectation
#   end
#
# end
