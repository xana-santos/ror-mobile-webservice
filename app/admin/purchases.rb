ActiveAdmin.register Purchase do
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
    column :amount
    column :trainer
    column :client
    column :status
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do
      row :id
      row :trainer
      row :client
      row :api_token
      row :amount
      row :status
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    panel "Products" do
      table_for purchase.product_purchases do
        column :title
        column :product_token do |p|
          p.product.api_token
        end
        column :unit_price
        column :quantity
        column :total
      end
    end
    active_admin_comments
  end
  
  filter :id
  filter :api_token
  filter :trainer, collection: proc { Trainer.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :client, collection: proc { Client.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :status, as: :select, collection: Purchase::STATUSES
  filter :amount
  
  before_filter do
    Purchase.class_eval do
      def to_param
        id.to_s
      end
    end
  end
  
end
