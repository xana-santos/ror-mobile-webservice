class AddClientDetailToClientAppointment < ActiveRecord::Migration
  def change
    add_reference :client_appointments, :client_detail
  end
end
