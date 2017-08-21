# require 'rails_helper'
#
# RSpec.describe Comment, type: :request do
#
#   let(:client){FactoryGirl.create(:client)}
#   let(:comment){FactoryGirl.create(:comment)}
#
#   let(:serialized){ CommentSerializer.new(comment).serializable_hash }
#   let(:deleted_serialized){ CommentSerializer.new(comment, show_deleted: true).serializable_hash }
#
#   let(:new_comment_params) do
#     {
#       "client_id"=> client.api_token,
#       "comment" => "Awesome client. 10/10 would train again.",
#       "comment_date" => "2015-08-08",
#       "comment_time" => "15:49"
#     }
#   end
#
#   let(:update_comment_params) do
#     {
#       "id" => comment.api_token,
#       "comment" => "Good-ish client. 7/10 might train again."
#     }
#   end
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/comment", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't create a new comment without required parameters" do
#     xhr :post, "/v1/comment", {}, json_headers
#     expect(response.status).to eq 400
#     expect(json["errors"].keys).to match_array ["client_id", "comment"]
#   end
#
#   it "successfully creates an comment" do
#     xhr :post, "/v1/comment", new_comment_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to eq "created"
#   end
#
#   it "successfully updates an comment" do
#     xhr :put, "/v1/comment", update_comment_params.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "updated"
#   end
#
#   it "successfully retrieves an comment" do
#     xhr :get, "/v1/comment", {id: comment.api_token}, json_headers
#     expect(response.status).to eq 200
#     expect(json).to match serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves a list of comments" do
#     comment
#     xhr :get, "/v1/comment/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"comments" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully retrieves only non-deleted comments if include_deleted is false" do
#     comment
#     comment.destroy!
#     xhr :get, "/v1/comment/list", {}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["comments"]).to_not include serialized.deep_stringify_keys
#   end
#
#   it "successfully retrieves deleted comments if include_deleted is true" do
#     comment
#     comment.destroy!
#     xhr :get, "/v1/comment/list", {include_deleted: true}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expect(json["meta"]).to include meta
#     expect(json["comments"]).to include deleted_serialized.deep_stringify_keys
#   end
#
#   it "successfully sets list offset and limit" do
#     xhr :get, "/v1/comment/list", {limit: 10, offset: 3}, json_headers
#     expect(response.status).to eq 200
#     meta = {"meta" =>{"total" => 0, "offset" => 3, "limit" => 10}}
#     expect(json).to include meta
#   end
#
#   it "returns no records if their last update was before timestamp" do
#     comment
#     xhr :get, "/v1/comment/list", {timestamp: (Time.now + 1.day).to_i}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 0, "offset" => 0, "limit" => 25}
#     expectation = {"comments" => [], "meta" => meta}
#     expect(json).to match expectation
#   end
#
#   it "successfully sets retrieves list for a client" do
#     xhr :get, "/v1/comment/list", {client_id: comment.client.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"comments" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to include expectation
#   end
#
#   it "successfully sets retrieves list for a trainer" do
#     xhr :get, "/v1/comment/list", {trainer_id: comment.trainer.api_token}, json_headers
#     expect(response.status).to eq 200
#     meta = {"total" => 1, "offset" => 0, "limit" => 25}
#     expectation = {"comments" => [serialized.deep_stringify_keys], "meta" => meta}
#     expect(json).to include expectation
#   end
#
#   it "successfully sets returns no list for a client without comments" do
#     xhr :get, "/v1/comment/list", {client_id: client.api_token}, json_headers
#     expect(response.status).to eq 200
#     expectation = {"comments" => []}
#     expect(json).to include expectation
#   end
#
#   it "successfully removes an comment" do
#     xhr :delete, "/v1/comment", {id: comment.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(comment.reload.deleted_at).to_not eq nil
#   end
#
#   it "successfully removes comments" do
#     xhr :delete, "/v1/comment", {ids: [comment.api_token]}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "deleted"
#     expect(comment.reload.deleted_at).to_not eq nil
#   end
#
#   it "wont restore an active comment" do
#     xhr :post, "/v1/comment/restore", {id: comment.api_token}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "does not exist"
#   end
#
#   it "successfully restores an comment" do
#     comment.update_column(:deleted_at, Time.now)
#     xhr :post, "/v1/comment/restore", {id: comment.api_token}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["status"]
#     expect(json["status"]).to eq "restored"
#     expect(comment.reload.deleted_at).to eq nil
#   end
#
# end
