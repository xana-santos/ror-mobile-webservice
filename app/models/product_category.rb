class ProductCategory < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  
  has_many :category_products
  has_many :products, through: :category_products
  
  acts_as_paranoid
  
end
