ActiveAdmin.register Address do
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
  
  index do
    selectable_column
    id_column
    column :api_token
    column :line_1
    column :line_2
    column :state
    column :suburb
    column :postcode
    column :record
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  filter :id
  filter :api_token
  filter :state, as: :select, collection: proc { Address.pluck("DISTINCT state").sort }
  filter :suburb
  filter :record_type
  
end
