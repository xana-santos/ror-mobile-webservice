class Referral < ActiveRecord::Base
  belongs_to :referrer, foreign_key: "referrer_id", class_name: "Trainer"
  belongs_to :referee, foreign_key: "referee_id", class_name: "Trainer"

  validates :referrer_id, presence: true, uniqueness: { scope: :referee_id }
  # validates :referrer_id, presence: true
  validates :referee_id, presence: true, uniqueness: true
  validate :check_referee_is_not_referrer
  validate :check_referrer_has_not_been_referred


  def check_referee_is_not_referrer
	  errors.add(:referee_id, "Can't refer self") if referee_id == referrer_id
	end

	def check_referrer_has_not_been_referred
	  existing_record = Referral.where(referee_id: referrer_id).where(referrer_id: referee_id).first
	  if (existing_record.present?)
	    errors.add(:base, "Can't have a circular referral")
	  end
	end
end


# index! do |format|
#         format.html
#         format.aba {
#           puts "in aba"
#         }
#       end