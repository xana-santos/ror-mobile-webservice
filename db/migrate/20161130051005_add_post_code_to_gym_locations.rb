class AddPostCodeToGymLocations < ActiveRecord::Migration
  def change
    add_column :gym_locations, :postcode, :string
  end
end
