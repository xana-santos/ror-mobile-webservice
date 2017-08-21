ActiveAdmin.register Comment, as: "ClientComment" do
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
  
  menu priority: 6
  
  index do
    selectable_column
    id_column
    column :api_token
    column :client
    column :trainer
    column :comment
    column :comment_date
    column :comment_time
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  filter :id
  filter :api_token
  filter :client, collection: proc { Client.all.uniq.map{|u| "#{u.name} - #{u.api_token} - ##{u.id}"} }
  filter :consultation_date
  
end
