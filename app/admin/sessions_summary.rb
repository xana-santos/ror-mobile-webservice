ActiveAdmin.register ClientSession, as: "Session Summary"  do
  include SharedAdmin
  # include CustomActions

  # get_admin_actions

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        super - ['edit', 'destroy', 'new']
      end
    end
  end

  menu priority: 1

  index do
    column :trainer_name do |client_session|
      if client_session.session.nil? 
        "Session is nil"
      else
        client_session.session.trainer
      end
    end
    column :trainer_email do |client_session|
      if client_session.session.nil?
        "Session is nil"
      else
        client_session.session.trainer.email
      end
    end
    column :date do |client_session|
      if client_session.session.nil?
        "Session is nil"
      else
        client_session.session.date
      end
    end
    column :session
    column :status
    actions
  end

  

  filter :trainer, as: :select, collection: proc { Trainer.all.uniq.map{|u| ["#{u.name} - #{u.api_token} - ##{u.id}", u.id]} }
  filter :status, as: :select, collection: %w[confirmed rejected cancelled paid attended unattended converted unconverted prospect]
  filter :session_date, as: :date_range, label: "Date Range"

  before_filter do
    ClientSession.class_eval do
      def to_param
        id.to_s
      end
    end
  end

end
