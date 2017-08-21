ActiveAdmin.register Invoice do
  include SharedAdmin

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        super - ['edit', 'destroy', 'new']
      end
    end
  end

  menu priority: 5

  index do
    selectable_column
    id_column
    column :api_token
    column :trainer
    column :record
    column :paid
    column :total
    column :subtotal
    column :fees
    column :payment_details
    column :attempts
    column :created_at
    column :deleted do |i|
      i.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do    
      row :id  
      row :api_token
      row :trainer
      row :record
      row :paid
      row :total
      row :subtotal
      row :fees
      row :payment_details
      row :attempts
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    panel "Items" do
      table_for invoice.invoice_items do |item|
        column :record
        column :item
        column :description
        column :subtotal
        column :quantity
        column :fees
        column :total
      end
    end
    active_admin_comments
  end
  
  filter :id
  filter :api_token
  filter :trainer, collection: proc { Trainer.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :client, collection: proc { Client.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :created_at, label: "Invoice Date"
  filter :record_type
  filter :paid, as: :boolean
  filter :total
  
  csv do
    column (:date){|invoice| invoice.created_at.strftime("%d/%m/%Y") }
    column("Session Date"){|invoice| invoice.try(:record).try(:date).try(:strftime, "%d/%m/%Y") }
    column("Session Time"){|invoice| invoice.try(:record).try(:time) }
    column("Session Duration"){|invoice| invoice.try(:record).try(:duration) }
    column ("Subtotal (ex GST)"){|invoice| invoice.subtotal_ex_gst.precision(2) if invoice.try(:trainer).try(:gst) }
    column ("Subtotal GST") {|invoice| invoice.subtotal_gst.precision(2) if invoice.try(:trainer).try(:gst) }
    column ("Subtotal") {|invoice| invoice.subtotal_dollars.round(2).precision(2) }
    column("Fees (ex GST)"){|invoice| invoice.fees_dollars.precision(2) }
    column("Fees GST"){|invoice| invoice.fees_gst.precision(2) }
    column("Fees"){|invoice| invoice.fees_dollars.round(2).precision(2) }
    column("Total"){ |invoice| invoice.total_dollars.round(2).precision(2) }
    column("Description"){ |invoice| invoice.csv_description }
    column("Client"){ |invoice| invoice.client.name }
    column("Reference"){ |invoice| invoice.stripe_id }
  end
  
end
