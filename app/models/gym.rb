class Gym < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  
  has_one :address, as: :record
  accepts_nested_attributes_for :address, allow_destroy: true
      
  has_many :trainer_gyms
  has_many :trainers, through: :trainer_gyms
  
  has_many :gym_locations, dependent: :destroy
  accepts_nested_attributes_for :gym_locations, allow_destroy: true
  
  delegate :full_address, to: :address, allow_nil: true

end
