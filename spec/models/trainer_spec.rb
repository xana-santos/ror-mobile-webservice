# require 'rails_helper'
#
# RSpec.describe Trainer, type: :model do
#
#   let(:trainer){FactoryGirl.build_stubbed(:trainer)}
#   let(:serialized){ TrainerSerializer.new(trainer).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :first_name, :last_name, :email, :mobile, :office, :phone, :address, :abn, :birthdate, :gym, :gym_location, :bank, :created_at, :identification, :image, :publishable_key, :targets, :verification, :gst]
#   end
#
# end
