class AddStatusToGymLocations < ActiveRecord::Migration
  def change
    add_column :gym_locations, :status, :string, default: "Open"
  end
end
