# require 'rails_helper'
#
# RSpec.describe User, type: :request do
#
#   let(:user){FactoryGirl.create(:user)}
#
#   it "rejects unauthorised token" do
#     xhr :post, "/v1/user/authenticate", {}, {}
#     expect(response.status).to eq 403
#     expect(response.body).to include "Unauthorized."
#   end
#
#   it "doesn't authorize a user with wrong credentials" do
#     xhr :post, "/v1/user/authenticate", {email: user.email, password: "wrong-password"}.to_json, json_headers
#     expect(response.status).to eq 400
#     expect(json.keys).to match_array ["errors"]
#     expect(json["errors"]).to include "Invalid email/password"
#   end
#
#   it "authorizes a user with correct credentials" do
#     xhr :post, "/v1/user/authenticate", {email: user.email, password: "password"}.to_json, json_headers
#     expect(response.status).to eq 200
#     expect(json.keys).to match_array ["id", "status"]
#     expect(json["status"]).to include "authenticated"
#   end
#
# end
