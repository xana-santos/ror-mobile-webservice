class AddExtraProspectNoteFieldsToAppointment < ActiveRecord::Migration
  def change
    add_column :appointments, :unconverted_note, :text
    add_column :appointments, :sessions_per_week, :integer
    add_column :appointments, :client_value_per_week, :integer
  end
end
