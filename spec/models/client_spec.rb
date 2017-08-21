require 'rails_helper'

RSpec.describe Client do

  let(:client){FactoryGirl.build(:client)}
  let(:serialized){ ClientSerializer.new(client).serializable_hash }

  it "should have a valid factory" do
    expect(client).to be_valid
  end

  it "should serialize correctly" do
    expect(serialized.keys).to match_array [:id, :first_name, :last_name, :email, :mobile, :office, :phone, :client_details, :addresses, :trainer, :created_at, :image, :active, :birthdate, :card, :mobile_preferred]
  end

end
