module UserAdmin
  extend ActiveSupport::Concern

  def self.included(base)
    
    base.instance_eval do
      
      scope "Active", :only_active
      scope "Inactive", :only_inactive
      
      batch_action :activate do |ids|
        User.find(ids).each do |user|
          user.activate!
        end
        redirect_to collection_path, alert: "Successfully activated."
      end
      
      batch_action :deactivate do |ids|
        User.find(ids).each do |user|
          user.deactivate!
        end
        redirect_to collection_path, alert: "Successfully deactivated."
      end
      
      
    end
  end

end
