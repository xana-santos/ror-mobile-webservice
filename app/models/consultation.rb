class Consultation < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  include DateAndTime::Zones

  belongs_to :client
  has_one :trainer, through: :client

  has_many :images, -> { order(position: :asc) }, as: :record

  cache_has_one :client, embed: true, inverse_name: :consultations
  delegate :trainer, to: :client

  accepts_nested_attributes_for :images, allow_destroy: true

end
