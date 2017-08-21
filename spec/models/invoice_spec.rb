# require 'rails_helper'
#
# RSpec.describe Invoice, type: :model do
#
#   let(:invoice){FactoryGirl.build_stubbed(:invoice)}
#   let(:serialized){ InvoiceSerializer.new(invoice).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:client, :description, :id, :generated, :items, :subtotal, :total, :trainer, :fees, :attempts, :paid, :payment_details, :record]
#   end
#
# end
