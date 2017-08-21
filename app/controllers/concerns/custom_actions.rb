module CustomActions
	def get_admin_actions
		controller do
		    def action_methods
		      if current_admin_user.is_super_admin?
		        super 
		      else
		        super - ['edit', 'destroy', 'new']
		      end
		    end
		  end
	end
end

::ActiveAdmin::DSL.send(:include, CustomActions)
