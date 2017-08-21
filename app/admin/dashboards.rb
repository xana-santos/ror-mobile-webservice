ActiveAdmin.register_page "Dashboard" do
  
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  
  content :title => proc{ I18n.t("active_admin.dashboard") } do
    
    div do
      render 'dashboard'
    end
    
  end
  
  controller do
    
    def index
      @session_rate = ClientSession.get_money_min_max("session_rate")
      @month_start = (Date.today - 30.days).beginning_of_day.to_time.to_i * 1000
      @daily_start = (Date.today - 7.days).beginning_of_day.to_time.to_i * 1000
      @weekly_start = (Date.today - 1.month).beginning_of_week.to_time.to_i * 1000
      @monthly_start = (Date.today - 1.year).beginning_of_day.to_time.to_i * 1000
    end
    
  end
  
end
