class AddStripeIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :stripe_id, :string
  end
end
