RSpec.shared_examples 'an API model' do

  it "should have db column api_token" do
    expect(model.attributes).to include(:api_token)
  end

end
