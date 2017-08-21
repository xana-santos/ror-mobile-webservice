FactoryGirl.define do

  factory :product do
    title "Test Product"
    product_id { SecureRandom.urlsafe_base64(5) }
    unit_price 12.00
    category "Cardio"
    cost 20.00
    categories{ [FactoryGirl.create(:product_category).api_token] }
    product_image { File.new("#{Rails.root}/spec/support/images/test_product_img.png") }
  end

end
