class AddPfloStripeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pflo_stripe_id, :string
  end
end
