ActiveAdmin.register Trainer do
  include SharedAdmin
  include UserAdmin

  permit_params :first_name, :last_name

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        super - ['edit', 'destroy', 'new']
      end
    end
  end

  menu priority: 1, parent: "Users"

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
    column :deleted do |p|
      p.deleted_at.blank? ? status_tag("no") : status_tag("yes", :ok)
    end
    actions
  end
  
  show do
    
    attributes_table do
      ::Trainer.column_names.reject{|i| ["reset_token", "reset_sent", "password_digest"].include? i}.each do |name|
        row(name){|c| c.send(name)}
      end
    end
    
  end
  
  filter :id
  filter :api_token
  filter :first_name
  filter :last_name
  filter :email
  
  before_filter do
    Trainer.class_eval do
      def to_param
        id.to_s
      end
    end
  end
  
  sidebar "Stripe", only: :show do
    attributes_table_for trainer do
      row :stripe_id
      row :abn
      row :birthdate
    end
  end
  
  sidebar "Address", only: :show do
    attributes_table_for trainer.address do
      row :line_1
      row :line_2
      row :suburb
      row :state
      row :postcode
    end
  end
  
  sidebar "Gym", only: :show do
    attributes_table_for trainer.gym_location do
      row("name"){|g| g.gym.name}
      row :name
      row :state
    end
  end

end
