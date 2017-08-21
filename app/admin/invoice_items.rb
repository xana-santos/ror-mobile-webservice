ActiveAdmin.register InvoiceItem do
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

  menu priority: 5, parent: "Invoices"

  index do
    selectable_column
    id_column
    column :api_token
    column :invoice
    column :record
    column :item
    column :description
    column :subtotal
    column :quantity
    column :fees
    column :total
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do    
      row :id  
      row :api_token
      row :item
      row :description
      row :subtotal
      row :quantity
      row :fees
      row :total
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    active_admin_comments
  end
  
  filter :id
  filter :api_token
  filter :invoice, collection: proc { Invoice.all.uniq.map{|u| "#{u.api_token} - ##{u.id}"} }
  filter :trainer, collection: proc { Trainer.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :client, collection: proc { Client.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :item
  filter :record_type
  filter :subtotal
  filter :total
  
end
