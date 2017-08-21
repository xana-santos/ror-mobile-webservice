# require 'rails_helper'
#
# RSpec.describe GymLocation, type: :model do
#
#   let(:gym_location){FactoryGirl.build_stubbed(:gym_location)}
#   let(:serialized){ GymLocationSerializer.new(gym_location, show_gym: true).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:gym, :id, :name, :phone_number, :postcode, :state, :status, :street_address, :suburb]
#   end
# end
