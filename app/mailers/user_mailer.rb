class UserMailer < ApplicationMailer

# this should not be here, all emails use the layout except test_email
  layout false
  def test_email(trainer)

#------------week date range---------
    start_of_this_week = Date.today.beginning_of_week
    end_of_this_week = Date.today.end_of_week
    @week_range_string = "#{start_of_this_week.strftime('%d/%m/%y')} - #{end_of_this_week.strftime('%d/%m/%y')}"
    puts @week_range_string


#------------weekly revenue------------
    
    start_of_last_week = start_of_this_week-7
    start_of_next_week = start_of_this_week+7
    start_of_2_weeks_from_now = start_of_this_week+14

    past_two_weeks_invoices = trainer.invoices.where("created_at >= ?", start_of_last_week).where("created_at < ?", start_of_next_week)

    this_weeks_total = 0
    last_weeks_total = 0

    past_two_weeks_invoices.each do |invoice|
      if invoice.created_at > start_of_this_week
        this_weeks_total += invoice.subtotal
      else
        last_weeks_total += invoice.subtotal
      end
    end


    this_weeks_total_string = sprintf('%.2f', this_weeks_total/100.0)
    puts "total made this week: $#{this_weeks_total_string}"
    last_weeks_total_string = sprintf('%.2f', last_weeks_total/100.0)
    puts "total made last week: $#{last_weeks_total_string}"

    @weekly_revenue = this_weeks_total_string

    # assuming earning is yearly
    if trainer.targets.earning.nil?
      @weekly_target = ""
      @difference = ""
      @w_rev_diff = ""
      @sign_class = "redText"
    else
      target_cents = trainer.targets.earning/(12*4)
      @weekly_target = sprintf('%.2f', (trainer.targets.earning/(12*4))/100.0)
      if target_cents > this_weeks_total 
        @difference = sprintf('%.2f', (target_cents-this_weeks_total)/100.0)
        @w_rev_diff = "-"
        @sign_class = "redText"
      else
        @difference = sprintf('%.2f', (this_weeks_total-target_cents)/100.0)
        @w_rev_diff = "+"
        @sign_class = "lightGreenText"
      end
    end


    # @weekly_revenue = 2450
    # @weekly_target = 3000
    
    

#------------difference from previous week------------

    if this_weeks_total > last_weeks_total
      @diff_sign = "+"
      @rev_diff = sprintf('%.2f', (this_weeks_total-last_weeks_total)/100.0)
    else
      @diff_sign = "-"
      @rev_diff = sprintf('%.2f', (last_weeks_total-this_weeks_total)/100.0)
    end
    
    


#------------projected revenue for next week------------
    next_weeks_client_sessions = trainer.client_sessions.where("client_sessions.created_at > ?", start_of_next_week).where("client_sessions.created_at < ?", start_of_2_weeks_from_now)
    projected_revenue = 0
    next_weeks_client_sessions.each do |client_session|
      projected_revenue += client_session.amount
    end


    @projected_revenue = sprintf('%.2f', (projected_revenue)/100.0)


#------------total sessions booked------------
    @session_count = 40
    @sessions_attended = 34


#------------cancellations------------
    @cancellations = 6
    @revenue_lost = 270


#------------revenue year to date------------
    @YTD_revenue = 65000
    @yearly_target = 90000


#------------client count------------
    @client_count = 18


#------------client growth------------
    @new_client_count = 2
    @lost_client_count = 1


#------------affiliate revenue------------
    @affiliate_revenue = 22

    mail(to: "ed.h@positivflo.com.au", subject: "test email")
  end

  def error_email(message, backtrace, request)
    @message = message
    @backtrace = backtrace
    @request = request
    mail(to: "kevin@positivflo.com", subject: "500 error occured - #{request[:method]} #{request[:path]}")
  end

  def basic_email
    mail(to: "kevin@positivflo.com", subject: "Test")
  end

  def client_welcome_email(client)
    @client = client
    mail(to: client.email, subject: "Welcome to Positiv Flo – Automated scheduling and billing for your Personal Training Appointments")
  end

  def trainer_welcome_email(trainer)
    @trainer = trainer
    mail(to: trainer.email, subject: "Welcome to Positiv Flo – We're Helping You Get Your Business Into Great Shape")
  end

  def reset_email(user)
    @user = user
    mail(to: user.email, subject: "Positiv Flo – Reset Your Password")
  end

  def csv_email(trainer, csv)
    attachments["Positiv Flo - #{trainer.name}.csv"] = {
      data: csv,
      content_type: "text/csv",
      mime_type: "text/csv"
    }
    @trainer = trainer
    mail(to: trainer.email, subject: "Positiv Flo – Your CSV File")
  end

  def payment_email(invoice)
    @invoice = invoice
    @client = invoice.client
    @trainer = @client.trainer
    mail(to: @client.email, subject: "Your Positiv Flo Payment")
  end

  def purchase_order_email(client, trainer, csv)
    @client = client
    @trainer = trainer

    attachments["Positiv Flo - Purchase Order for #{@client.name}.csv"] = {
      data: csv,
      content_type: "text/csv",
      mime_type: "text/csv"
    }
    #mail(to: "l.faulkner33@gmail.com", subject: "Purchase order for #{@client.name}")
  end

  def rate_change_email(trainer, client)
    @client = client
    @trainer = trainer
    mail(to: @client.email, subject: 'Your session rate has changed')
  end
end
