class ClientAppointment < ActiveRecord::Base
  belongs_to :client, touch: true
  belongs_to :client_detail, touch: true
  belongs_to :appointment, touch: true

  delegate :first_name, :last_name, :email, to: :client

end
