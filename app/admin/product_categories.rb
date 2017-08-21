ActiveAdmin.register ProductCategory do
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
  
  permit_params :category, :description, :api_token, :deleted_at

  menu priority: 6, parent: "Products"

  index do
    selectable_column
    id_column
    column :api_token
    column :category
    column :description
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end

  filter :id
  filter :api_token
  filter :category
  filter :description

end
