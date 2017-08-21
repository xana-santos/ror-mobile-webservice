# require 'rails_helper'
#
# RSpec.describe Consultation, type: :model do
#
#   let(:consultation){FactoryGirl.build_stubbed(:consultation)}
#   let(:serialized){ ConsultationSerializer.new(consultation).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :chest, :hips, :weight, :waist, :lean_body_weight, :body_fat_weight, :measurement, :left_arm, :right_arm, :glutes, :left_quads, :right_quads, :right_calf, :left_calf, :total_measurement, :fat_percentage, :comments, :consultation_date, :consultation_time, :client, :images, :trainer]
#   end
#
# end
