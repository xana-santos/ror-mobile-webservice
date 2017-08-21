ActiveAdmin.register Client do
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

  menu priority: 2, parent: "Users"

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
  filter :trainer, collection: proc { Trainer.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }

  show do

    attributes_table do
      ::Client.column_names.reject{|i| ["reset_token", "reset_sent", "password_digest", "abn", "office", "phone"].include? i}.each do |name|
        row(name){|c| c.send(name)}
      end
    end

  end

  before_filter do
    Client.class_eval do
      def to_param
        id.to_s
      end
    end
  end

  sidebar "Trainer", only: :show do
    attributes_table_for client.trainer do
      row("name"){|t| link_to t.name, admin_trainer_path(t.id)}
      row("Email"){ |t| t.email }
      row :id
      row :api_token
    end
  end

end
