class AddNameToGymLocations < ActiveRecord::Migration
  def change
    add_column :gym_locations, :name, :string
  end
end
