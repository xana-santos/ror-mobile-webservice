class AddGstToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gst, :boolean, default: true
  end
end
