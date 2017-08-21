# require 'rails_helper'
#
# RSpec.describe Gym, type: :model do
#
#   let(:gym){FactoryGirl.build_stubbed(:gym)}
#   let(:serialized){ GymSerializer.new(gym).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :name, :locations]
#   end
#
# end
