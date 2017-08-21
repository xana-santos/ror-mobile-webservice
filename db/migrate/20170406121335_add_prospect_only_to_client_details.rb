class AddProspectOnlyToClientDetails < ActiveRecord::Migration
  def change
    add_column :client_details, :prospect_only, :boolean
  end
end
