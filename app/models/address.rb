class Address < ActiveRecord::Base
  include TokenGenerator
  include IdentityCache
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  belongs_to :record, polymorphic: true, touch: true
  attr_accessor :type
  
  before_validation :set_address_type
    
  def set_address_type
    self.address_type = self.type unless self.type.blank?
  end
  
  def full_address
    [line_1, line_2, suburb, state, postcode].reject(&:blank?).join(", ")
  end
  
  def geocodable_address
    [line_1, line_2, suburb, state, postcode, "Australia"].reject(&:blank?).join(", ")
  end
  
end
