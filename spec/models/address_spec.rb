# RSpec.describe Address, type: :model do
#
#   let(:address){FactoryGirl.build_stubbed(:address)}
#   let(:serialized){ AddressSerializer.new(address, show_id: true).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should generate a full address" do
#     expect(address.full_address).to_not eq nil
#   end
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :line_1, :line_2, :suburb, :state, :postcode, :main_address, :type]
#   end
#
# end
