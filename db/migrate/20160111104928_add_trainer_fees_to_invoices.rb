require 'migration_data'
class AddTrainerFeesToInvoices < ActiveRecord::Migration
  
  def change
    add_column :invoices, :trainer_fees, :integer
  end
  
  def data
    Invoice.update_all(trainer_fees: (Settings.fees.trainer*(1+Settings.fees.gst_percent)).round)
  end
  
end
