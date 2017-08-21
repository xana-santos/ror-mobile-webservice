class Product < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  mount_uploader :product_image, ProductImageUploader

  acts_as_paranoid

  has_many :product_purchases
  has_many :purchases, through: :product_purchases

  has_many :category_products
  has_many :product_categories, through: :category_products

  attr_accessor :categories

  after_save :associate_categories

  def associate_categories
    if categories
      category_products.destroy_all
      # TODO: Implement ability to add multiple categories
      # categories.each do |c|
      category = ProductCategory.find_by(api_token: categories)
      category_products.create!(product_category: category) unless category.blank?
      # end
    end
  end

end
