ActiveAdmin.register User do
  include SharedAdmin
  include UserAdmin

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        super - ['edit', 'destroy', 'new']
      end
    end
  end
  
  menu priority: 2

  index do
    selectable_column
    id_column
    column :api_token
    column :name
    column :email
    column :mobile
    column :office
    column :phone
    column :active
    column :abn
    column :type
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  filter :id
  filter :api_token
  filter :first_name
  filter :last_name
  filter :email
  filter :type, as: :select

end
