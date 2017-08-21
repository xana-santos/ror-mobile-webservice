class ChangeColumnNumBulkSessionsInClientDetails < ActiveRecord::Migration
  def change
  	change_column :client_details, :num_bulk_sessions, :decimal
  end
end
