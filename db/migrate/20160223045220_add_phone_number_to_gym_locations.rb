class AddPhoneNumberToGymLocations < ActiveRecord::Migration
  def change
    add_column :gym_locations, :phone_number, :string
  end
end
