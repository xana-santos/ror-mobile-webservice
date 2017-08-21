require 'rails_helper'

RSpec.describe Session, type: :model do

  let(:session){FactoryGirl.build_stubbed(:session)}
  let(:serialized){ SessionSerializer.new(session).serializable_hash }

  it "should have a valid factory" do
    expect(session).to be_valid
  end

  it "should serialize correctly" do
    expect(serialized.keys).to include(:id, :date, :time, :session_rate, :appointment, :clients)
  end

end
