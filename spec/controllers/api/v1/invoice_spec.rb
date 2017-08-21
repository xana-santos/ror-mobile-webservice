# require 'rails_helper'
#
# RSpec.describe Invoice, type: :request do
#
#   let(:invoice){FactoryGirl.create(:invoice)}
#   let(:client){ FactoryGirl.create(:client) }
#   let(:trainer){ FactoryGirl.create(:trainer) }
#
#   let(:serialized){ InvoiceSerializer.new(invoice).serializable_hash }
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/invoice", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "successfully retrieves an invoice" do
#     xhr :get, "/v1/invoice", {id: invoice.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of invoices" do
#     invoice
#     xhr :get, "/v1/invoice/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoices" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully generates a csv" do
#     invoice
#     xhr :get, "/v1/invoice/send_csv", {trainer_id: trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/invoice/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     invoice
#     xhr :get, "/v1/invoice/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"invoices" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves list for a client" do
#     xhr :get, "/v1/invoice/list", {client_id: invoice.client.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoices" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["invoices"]).to include expectation["invoices"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a client without invoices" do
#     xhr :get, "/v1/invoice/list", {client_id: client.api_token}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"invoices" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully retrieves list for a trainer" do
#     xhr :get, "/v1/invoice/list", {trainer_id: invoice.trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoices" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["invoices"]).to include expectation["invoices"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a trainer without invoices" do
#     xhr :get, "/v1/invoice/list", {trainer_id: trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"invoices" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully retrieves list for a type" do
#     invoice
#     xhr :get, "/v1/invoice/list", {record_type: "client_session"}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"invoices" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json["invoices"]).to include expectation["invoices"][0]
#     expect(json["meta"]).to match expectation["meta"]
#   end
#
#   it "successfully returns no list for a type without invoices" do
#     invoice
#     xhr :get, "/v1/invoice/list", {record_type: "purchase"}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"invoices" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully retries a payment" do
#     invoice
#     xhr :get, "/v1/invoice/retry", {id: invoice.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status", "paid", "payment_details"]
#   end
#
#
# end
