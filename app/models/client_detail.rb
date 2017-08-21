class ClientDetail < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :user, touch: true

  has_many :client_appointments

  after_save :notify_rate_changed, if: -> (obj) {obj.session_rate_changed?}

  def notify_rate_changed
    self.client_appointments.each do |appointment|
      UserMailer.rate_change_email(appointment.trainer, self).deliver_now
    end
  end

end
