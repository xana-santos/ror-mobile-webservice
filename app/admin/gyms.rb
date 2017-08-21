ActiveAdmin.register Gym do
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
  
  menu priority: 4

  index do
    selectable_column
    id_column
    column :name
    # column :api_token
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do    
      row :id  
      row :api_token
      row :name
      row :created_at
      row :updated_at
      row :deleted_at
    end
    
    panel "Locations" do
      table_for gym.gym_locations do |location|
        column :name
        column :street_address
        column :state
        column :timezone
        column :status
        column :api_token
      end
    end
    active_admin_comments
  end

  filter :id
  filter :api_token
  filter :name
  # filter :address_state, as: :select, collection: proc { Address.pluck("DISTINCT state").sort }
  # filter :address_suburb, as: :string
  # filter :address_postcode, as: :string
  
end
