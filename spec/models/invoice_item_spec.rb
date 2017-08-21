# require 'rails_helper'
#
# RSpec.describe InvoiceItem, type: :model do
#
#   let(:invoice_item){FactoryGirl.create(:invoice_item)}
#   let(:serialized){ InvoiceItemSerializer.new(invoice_item).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:description, :id, :item, :quantity, :subtotal, :total, :record, :fees]
#   end
#
# end
