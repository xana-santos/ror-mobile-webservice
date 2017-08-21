ActiveAdmin.register Trainer, as: "Affiliate Summary" do
  # include SharedAdmin
  # include UserAdmin

  # includes :client_sessions, :sessions

  permit_params :id, :first_name, :last_name, :referrer

  scope :all, default: true
  scope :with_referrals do |trainers|
    trainers.joins( "RIGHT OUTER JOIN referrals ON referrals.referrer_id = users.id" ).group( "users.id" )
  end


controller do
  def action_methods
    if current_admin_user.is_super_admin?
      super 
    else
      super - ['edit', 'destroy', 'new']
    end
  end

  def index
    @test = "test"
    @filter_params = params[:q]
    if @filter_params.nil?
      @filter_gt = 1.year.ago.strftime('%Y-%m-%d')
      @filter_lt = ( Time.now + 1.year ).strftime('%Y-%m-%d')
    else
      @filter_gt = @filter_params[:sessions_client_sessions_date_gteq_datetime]
      @filter_lt = @filter_params[:sessions_client_sessions_date_lteq_datetime]
    end  
    
    index! do |format|
      format.html
      format.aba do
        puts "in aba"

        aba = Aba.batch(
          bsb: "306-089",
          financial_institution: "BWA",
          user_name: "Positiv Flo Pty Ltd",
          user_id: "000000",
          description: "Affiliate",
          process_at: Time.now.strftime("%d%m%y")
        )

        10.times do
          aba.add_transaction(
            {
              bsb: "342-342",
              account_number: "3244654",
              amount: 10000, # Amount in cents
              account_name: "John Doe",
              transaction_code: 53,
              lodgement_reference: "affiliate",
              trace_bsb: "306-089",
              trace_account_number: "3601596",
              name_of_remitter: "Remitter"
            }
          )
        end

        send_data aba.to_s, filename: "test.ABA"
        
      end
    end
  end


  def update
    referrer_id = params[:trainer].delete(:referrer)
    trainer_param = params[:trainer]
    trainer = Trainer.find(trainer_param[:id])
    trainer.referrer = Trainer.find(referrer_id)
    
    super
    # product.creator = current_user
  end
  # def permitted_params
  #   params.permit!
  # end
end

menu priority: 2

index :download_links => [:csv, :aba] do
    selectable_column
    # column :name
    column :name do |trainer|
      link_to trainer.name, admin_affiliate_summary_path(trainer)
    end
    # column :was_referred_by do |trainer|
    #   trainer.referrer
    # end
    column "# Refferals" do |trainer|
      trainer.referees.count
    end
    column "Total Sessions By Referals" do |trainer|
      # puts controller.instance_variable_get(:@test)
      trainer_referees = trainer.referees
      if trainer_referees.count == 0
        0
      else
        total_num_cs = 0
        trainer_referees.each do |referee|
          # total_num_cs += referee.client_sessions.count
          this_referees_sessions = referee.sessions.where("date >= ?", controller.instance_variable_get(:@filter_gt)).where("date <= ?", controller.instance_variable_get(:@filter_lt))
          total_client_sessions = 0
          this_referees_sessions.each do |session|
            total_client_sessions += session.client_sessions.count
          end
          total_num_cs += total_client_sessions
        end
        total_num_cs
      end
    end
    column "Total Earned" do |trainer|
      trainer_referees = trainer.referees
      # puts "number of referees: #{trainer_referees.count}"
      if trainer_referees.count == 0
        0.0
      else
        total_num_cs = 0
        trainer_referees.each do |referee|
          # total_num_cs += referee.client_sessions.count
          this_referees_sessions = referee.sessions.where("date >= ?", controller.instance_variable_get(:@filter_gt)).where("date <= ?", controller.instance_variable_get(:@filter_lt))
          total_client_sessions = 0
          this_referees_sessions.each do |session|
            total_client_sessions += session.client_sessions.count
          end
          total_num_cs += total_client_sessions
        end
        # puts "total_num_cs: #{total_num_cs}"
        total_num_cs*0.5
      end
    end
    
    actions
  end
  

  
  # filter :id
  # filter :api_token
  # filter :first_name
  # filter :last_name
  # filter :email
  # filter :client_sessions_date, as: :date_range, label: "Date Range"
  filter :sessions_client_sessions_date, as: :date_range, label: "Sessions Date Range"
  
  before_filter do
    Trainer.class_eval do
      def to_param
        id.to_s
      end
    end
  end


  show :title => :name do
    panel "Referrals Performance" do
      table_for(affiliate_summary.referees) do
        column("Name", :sortable => :id)  {|referee| referee.name }
        column("# Sessions") do |referee|
          referee.client_sessions.count
        end
        column("Total Earned") do |referee|
          referee.client_sessions.count*0.5
        end
      end
    end    
  end

  sidebar "Customer Details", :only => :show do
    attributes_table_for affiliate_summary, :first_name, :last_name, :email, :referrer
  end



  form do |f|
    f.inputs "Affiliate Details" do
      # puts :referrer_first_name
      f.input :id
      f.input :first_name
      # f.collection_select :referrer, Trainer.all, :id, :name, :selected => 1
      # f.input :referrer, :as => :check_boxes, :collection => Trainer.all.collect {|x| [x.name, x.id]}
      # f.input :referrer, :as => :select, :collection => Trainer.all.collect {|x| [x.name, x.id]}, {}
      f.select :referrer, Trainer.all.collect {|x| [x.name, x.id]}, {}
      # f.select :referrer, Trainer.all.collect {|x| [x.name, x.id]}, {}
      # f.select :referrer, Trainer.all.collect {|x| [x.name, x.id]}

      # f.input :referrer_id
      
      # f.inputs do
      #   f.has_many :referrer, heading: 'Referred By',
      #                           allow_destroy: true,
      #                           new_record: false do |a|
      #     a.input :id
      #   end
      # end
    end
    f.actions  
  end

end
