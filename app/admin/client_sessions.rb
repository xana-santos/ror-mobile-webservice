ActiveAdmin.register ClientSession do
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
  
  menu priority: 4, parent: "Appointments"

  index do
    selectable_column
    id_column
    column :api_token
    column :client
    column :session
    column :status
    column :charge_percent
    column :amount
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do    
      row :id  
      row :api_token
      row :client
      row :session
      row :status
      row :charge_percent
      row :amount
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    active_admin_comments
  end
  
  filter :id
  filter :api_token
  filter :session, collection: proc { Session.all.uniq.map{|u| "#{u.api_token} - ##{u.id}"} }
  filter :client, collection: proc { Client.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :time
  
  before_filter do
    ClientSession.class_eval do
      def to_param
        id.to_s
      end
    end
  end

end
