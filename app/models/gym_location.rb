require 'nearest_time_zone'
class GymLocation < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  
  belongs_to :gym
  
  geocoded_by :geocodable_address

  after_validation :geocode, if: -> (obj) {obj.location_changed? || obj.latitude.blank? || obj.longitude.blank?}
  after_validation :set_timezone, if: -> (obj){ obj.timezone.blank? || obj.latitude_changed? || obj.longitude_changed? }
  
  scope :by_associations, -> (filters={}){ by_gym(filters["gym_id"]) }
  scope :by_gym, -> (gym){ gym.blank? and all or joins(:gym).where(gyms: {api_token: gym})  }

  def geocodable_address
    [self.street_address, self.suburb, self.state, 'Australia'].join(',')
  end
  
  def set_timezone
    self.timezone = NearestTimeZone.to(latitude, longitude) rescue "UTC"
  end
  
  def offset
    ActiveSupport::TimeZone.new(timezone).now.formatted_offset
  end

  def location_changed?
    self.street_address_changed? || self.suburb_changed? || self.state_changed?
  end

end
