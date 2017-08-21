# require 'rails_helper'
#
# RSpec.describe Purchase, type: :model do
#
#   let(:purchase){FactoryGirl.build_stubbed(:purchase)}
#   let(:serialized){ PurchaseSerializer.new(purchase).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :amount, :status, :products, :client, :trainer]
#   end
#
# end
