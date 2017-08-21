module SharedAdmin
  extend ActiveSupport::Concern
  
  def self.included(base)
    base.instance_eval do
      scope "All", :with_deleted, default: true
      scope("Non-Deleted") { |scope| scope.where(deleted_at: nil) }
      scope "Deleted", :only_deleted
    end
  end

end
