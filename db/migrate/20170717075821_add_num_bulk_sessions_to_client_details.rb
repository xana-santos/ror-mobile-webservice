class AddNumBulkSessionsToClientDetails < ActiveRecord::Migration
  def change
    add_column :client_details, :num_bulk_sessions, :integer, default: 0
  end
end
