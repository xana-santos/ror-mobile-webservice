ActiveAdmin.register GymLocation do
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
  
  menu priority: 4, parent: "Gyms"

  index do
    selectable_column
    id_column
    column :name
    column :state
    column :timezone
    column :status
    column :api_token
    column :gym
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end

  filter :id
  filter :name
  filter :api_token
  filter :state
  filter :timezone
  filter :gym, collection: proc { Gym.all.uniq.map{|u| "#{u.name}"} }
  
end
