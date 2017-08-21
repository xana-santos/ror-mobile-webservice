# require 'rails_helper'
#
# RSpec.describe User, type: :model do
#
#   let(:user){FactoryGirl.build_stubbed(:user)}
#   let(:serialized){ UserSerializer.new(user).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :email, :first_name, :last_name]
#   end
#
# end
