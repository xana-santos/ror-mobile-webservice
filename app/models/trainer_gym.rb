class TrainerGym < ActiveRecord::Base
  has_one :gym, through: :gym_location
  belongs_to :gym_location
  belongs_to :trainer, touch: true
end
