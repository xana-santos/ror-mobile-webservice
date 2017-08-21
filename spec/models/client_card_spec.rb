# require 'rails_helper'
#
# RSpec.describe ClientCard, type: :model do
#
#   let(:client_card){FactoryGirl.build_stubbed(:client_card)}
#   let(:serialized){ ClientCardSerializer.new(client_card).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:last_4, :brand, :country]
#   end
#
# end
