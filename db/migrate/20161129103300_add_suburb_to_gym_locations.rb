class AddSuburbToGymLocations < ActiveRecord::Migration
  def change
    add_column :gym_locations, :suburb, :string
  end
end
