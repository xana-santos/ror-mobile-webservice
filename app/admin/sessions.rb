ActiveAdmin.register Session do
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
  
  menu priority: 3, parent: "Appointments"

  index do
    selectable_column
    id_column
    column :api_token
    column :appointment
    column :date
    column :time
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do    
      row :id  
      row :api_token
      row :appointment
      row :date
      row :time
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    panel "Client Sessions" do
      table_for session.client_sessions do |item|
        column :client
        column :status
        column :charge_percent
        column :amount
      end
    end
    active_admin_comments
  end
  
  filter :id
  filter :api_token
  filter :appointment, collection: proc { Appointment.all.uniq.map{|u| "#{u.api_token} - ##{u.id}"} }
  filter :date
  filter :time

end
