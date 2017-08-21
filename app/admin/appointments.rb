ActiveAdmin.register Appointment do
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
  
  menu priority: 3

  index do
    selectable_column
    id_column
    column :api_token
    column :client
    column :start_date
    column :start_time
    column :end_date
    column :end_time
    column :all_day_event
    column :private_event
    column :session_rate do |p|
      number_to_currency(p.session_rate/100.00)
    end
    column :repeat_after
    column :duration
    column :event_type
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  filter :id
  filter :api_token
  filter :appointment_clients, as: :select, collection: proc { Client.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }, label: "Client"
  filter :trainer, as: :select, collection: proc { Trainer.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }
  filter :session_rate
  filter :duration
  filter :start_date
  filter :end_date

end
