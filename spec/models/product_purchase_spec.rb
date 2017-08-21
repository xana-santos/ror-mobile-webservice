# require 'rails_helper'
#
# RSpec.describe ProductPurchase, type: :model do
#
#   let(:product_purchase){ FactoryGirl.build_stubbed(:product_purchase) }
#   let(:serialized){ ProductPurchaseSerializer.new(product_purchase).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :quantity, :unit_price, :title, :total]
#   end
#
#   it "should set total after save" do
#     expect(product_purchase.set_total).to eq (product_purchase.unit_price * product_purchase.quantity)
#     expect(product_purchase.amount).to eq product_purchase.total
#   end
#
# end
