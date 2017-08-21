# require 'rails_helper'
#
# RSpec.describe Product, type: :model do
#
#   let(:product){FactoryGirl.build_stubbed(:product)}
#   let(:serialized){ ProductSerializer.new(product).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :title, :description, :product_id, :unit_price, :unit_type, :categories, :status, :out_of_stock, :cost, :images]
#   end
#
# end
