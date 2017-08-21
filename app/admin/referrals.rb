ActiveAdmin.register Referral do
  # include SharedAdmin

  controller do
    def action_methods
      if current_admin_user.is_super_admin?
        super 
      else
        # super - ['edit', 'destroy', 'new']
        super
      end
    end
  end


  action_item :only => :index do
    link_to 'Upload Referrals CSV', :action => 'upload_referrals_csv'
  end

  collection_action :upload_referrals_csv do
    render "admin/csv/upload_referrals_csv"
  end

  collection_action :import_csv, :method => :post do
    ReferralCSV.read_referrals(params[:dump][:all])
    redirect_to :action => :index, :notice => "DUN"
  end
  
  # permit_params :category, :description, :api_token, :deleted_at

  menu priority: 1

  index do
    id_column
    column :referrer_id
    column :referee_id
    actions
  end

  filter :id

end
