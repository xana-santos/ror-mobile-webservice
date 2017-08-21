class TrainerTarget < ActiveRecord::Base
  belongs_to :trainer, touch: true
end
