# require 'rails_helper'
#
# RSpec.describe Comment, type: :model do
#
#   let(:comment){FactoryGirl.build_stubbed(:comment)}
#   let(:serialized){ CommentSerializer.new(comment).serializable_hash }
#
#   it_behaves_like 'a Paranoid model'
#   it_behaves_like 'an API model'
#
#   it "should serialize correctly" do
#     expect(serialized.keys).to match_array [:id, :comment, :comment_date, :comment_time, :client, :trainer]
#   end
#
# end
