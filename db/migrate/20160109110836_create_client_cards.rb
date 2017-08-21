class CreateClientCards < ActiveRecord::Migration

  def up

    create_table :client_cards do |t|
      t.integer :client_id
      t.string :last_4
      t.string :brand
      t.string :country
      t.datetime :deleted_at
      t.string :api_token
      t.timestamps null: false
    end
    
    add_index :client_cards, :client_id
    add_index :client_cards, :deleted_at
    add_index :client_cards, :api_token
    
    Client.all.each do |client|
      client.update_stripe(client.stripe_customer) if client.stripe_id
    end
    
    remove_column :users, :last_4
    
  end
  
  def down
    add_column :users, :last_4, :string
    
    Client.all.each do |client|
      client.update_attributes(last_4: client.client_card.last_4) if client.client_card
    end
    
    drop_table :client_cards
  end
  
end
