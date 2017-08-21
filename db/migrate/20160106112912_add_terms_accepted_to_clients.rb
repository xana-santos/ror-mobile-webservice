require 'migration_data'
class AddTermsAcceptedToClients < ActiveRecord::Migration
  
  def change
    add_column :users, :terms_accepted, :boolean, default: false
  end
  
  def data
    Client.update_all(terms_accepted: true)
  end
  
end
