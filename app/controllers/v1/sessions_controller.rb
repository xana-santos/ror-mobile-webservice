class V1::SessionsController < ApiController
  include SessionFunctions

  def index

    offset = params[:offset] || 0
    limit = params[:limit] || 25

    start_datetime = params["start"] || {date: params["start_date"], time: params["start_time"]}
    end_datetime = params["end"] || {date: params["end_date"], time: params["end_time"]}

    sessions = ::Session.by_time(start_datetime, end_datetime).by_associations(params)

    filtered = sessions.filtered(params).order(created_at: :desc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i}

    
    #render json: filtered, root: "sessions", paid: params["paid"], meta: metadata, status: 200 and return
     render json: filtered, root: "sessions", paid: params["paid"], show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
  

  end

  def show

    # session = ::Session.fetch_by_api_token(params["id"])
    session = Session.find_by(api_token: params["id"])
    check_exists session or return
    render json: session, root: false, status: 200 and return

  end

  def cancel
    ap "(--- SESSION#CANCEL ---)"
    ap params
    # session = ::Session.fetch_by_api_token(params["id"])
    session = Session.find_by(api_token: params["id"])

    check_exists session or return

    show_errors("This session cannot be cancelled") or return unless session.cancellable?
    appointment = session.appointment

    SessionCancellor.new(appointment, session).cancel
    appointment.destroy if appointment.sessions.count.eql? 0

    render json: {status: "cancelled"}, status: 200 and return
  end

  def attendance
    # session = ::Session.fetch_by_api_token(params["id"])
    session = Session.find_by(api_token: params["id"])
    check_exists session or return

    client_sessions = session.client_sessions.by_clients(params["clients"].map{|c| c["id"]})
    params["clients"].each do |params|
    client_session = client_sessions.find{|cs| cs.client["api_token"] == params["id"]}

    check_exists(client_session, "client") or return

    client_session.update_attributes(params.except(:action, :controller, :id).permit!)
    # Charge clients explicity rather than using an after_save hook
    client_session.generate_invoice
    end

    render json: client_sessions, each_serializer: ClientPaymentSerializer, root: "clients", status: 200 and return

  end




  def update
    ap "(--- SESSION#UPDATE ---)"
    # old shit
    # This is actually called when you edit the date and time for an appointment
    # It's a huge hack because the iOS developer said the iOS code was too hard to change.
    # Ideally, we want all of this to be called somewhere else.
    # Also session#create is still called on own_time appointments which have no sessions.
    # Ideally, that should be called on Appointment#update.
    # end of old shit

    # appointment = Appointment.find_by(api_token: params["appointment_id"])
    #
    # unless check_exists(appointment, "appointment")
    #   trainer = appointment.trainer
    #   appointment = trainer.appointments.new(start_date: params[:date], end_date: params[:date], )
    # end
    #
    # duration = appointment.duration
    # end_time = (Time.parse(params[:time]) + duration*60).strftime("%H:%M")
    #
    # if appointment.sessions.count > 0
    #   # Maybe appiontment.event_type.eql? appointment
    #   if appointment.repeat_after.eql?  "never"
    #     ap "Single appointment session"
    #
    #     appointment.sessions.delete_all
    #     session = appointment.sessions.find_or_create_by(date: params["date"])
    #
    #     session.update_attributes(params.except(:action, :controller, :appointment_id).permit!)
    #     appointment.update_attributes({start_date: session.date,
    #                                    end_date: session.date,
    #                                    start_time: session.time,
    #                                    end_time: end_time})
    #
    #     session.client_sessions.each do |client_session|
    #       client_session.confirm!
    #     end
    #   else
    #     session = appointment.sessions.find_by(date: params["date"])
    #     session.update(time: params[:time])
    #   end
    # else
    #   updated_api_token = appointment.delete_day(params["date"]) if params["status"].eql? "cancelled"
    # end
    #
    # session.nil? ? api_token = updated_api_token : api_token = session.api_token

    # Major hack, because the ios calls session#create.
    # Even though my_own_time appointments have no sessions....
    appointment = Appointment.find_by(api_token: params["appointment_id"])
    api_token = appointment.sessions.first.api_token
    


    session = get_session
    check_exists session or return
    # validation: check_update_appointment(params, appointment) or return
    session.update_attributes(time: params[:time], date: params[:date])

# update parent appointment time if this session is the first or last of a recurring appointment
    appointment_sessions = appointment.sessions.order(utc_datetime: :asc)
    appointment.update_attributes(end_time: (Time.parse(appointment_sessions.last[:time]) + appointment.duration.minutes).to_s(:time), end_date: appointment_sessions.last[:date])
    appointment.update_attributes(start_time: appointment_sessions.first[:time], start_date: appointment_sessions.first[:date])

    # if appointment_sessions.last.api_token == params["id"]
    #   penultimate_session = appointment_sessions.last(2).first  #this is shitty
    #   puts "penultimate_session[:time] | [:date]"
    #   puts penultimate_session[:time]
    #   puts penultimate_session[:date]

    #   if penultimate_session[:utc_datetime] > session[:utc_datetime]
    #     puts "before last after this"
    #     t = Time.parse(penultimate_session[:time])
    #     puts "new time"
    #     puts (t + appointment.duration.minutes).to_s(:time)
    #     appointment.update_attributes(end_time: (t + appointment.duration.minutes).to_s(:time), end_date: penultimate_session[:date])
    #   else
    #     puts "this is still last"
    #     t = Time.parse(params[:time])
    #     appointment.update_attributes(end_time: (t + appointment.duration.minutes).to_s(:time), end_date: params[:date])
    #   end
    # end

    # if appointment_sessions.first.api_token == params["id"]
    #   second_session = appointment_sessions.second
    #   puts "second_session[:time] | [:date]"
    #   puts second_session[:time]
    #   puts second_session[:date]

    #   if second_session[:utc_datetime] < session[:utc_datetime]
    #     appointment.update_attributes(start_time: second_session[:time], start_date: second_session[:date])
    #   else
    #     appointment.update_attributes(start_time: params[:time], start_date: params[:date])
    #   end
    # end

    render json: {id: api_token, status: "updated"}, status: 200 and return
  end

  def create
    ap "(--- SESSION#CREATE ---)"
    # This is actually called when you edit the date and time for an appointment
    # It's a huge hack because the iOS developer said the iOS code was too hard to change.
    # Ideally, we want all of this to be called somewhere else.
    # Also session#create is still called on own_time appointments which have no sessions.
    # Ideally, that should be called on Appointment#update.

    appointment = Appointment.find_by(api_token: params["appointment_id"])

    unless check_exists(appointment, "appointment")
      trainer = appointment.trainer
      appointment = trainer.appointments.new(start_date: params[:date], end_date: params[:date], )
    end

    duration = appointment.duration
    end_time = (Time.parse(params[:time]) + duration*60).strftime("%H:%M")

    if appointment.sessions.count > 0
      # Maybe appiontment.event_type.eql? appointment
      if appointment.repeat_after.eql?  "never"
        ap "Single appointment session"

        appointment.sessions.delete_all
        session = appointment.sessions.find_or_create_by(date: params["date"])

        session.update_attributes(params.except(:action, :controller, :appointment_id).permit!)
        appointment.update_attributes({start_date: session.date,
                                       end_date: session.date,
                                       start_time: session.time,
                                       end_time: end_time})

        session.client_sessions.each do |client_session|
          client_session.confirm!
        end


      else
        session = appointment.sessions.find_by(date: params["date"])
        session.update(time: params[:time])
      end
    else
      updated_api_token = appointment.delete_day(params["date"]) if params["status"].eql? "cancelled"
    end

    session.nil? ? api_token = updated_api_token : api_token = session.api_token

    # Major hack, because the ios calls session#create.
    # Even though my_own_time appointments have no sessions....
    render json: {id: api_token, status: "created"}, status: 200 and return

  end

  def resend
    # session = ::Session.fetch_by_api_token(params["id"])
    session = Session.find_by(api_token: params["id"])

    check_exists session or return

    client_sessions = session.client_sessions.by_clients(params["clients"].map{|c| c["id"]})

    params["clients"].each do |params|
      client_session = client_sessions.find{|cs| cs.client["api_token"] == params["id"]}
      check_exists(client_session, "client") or return

      show_errors("You may only resend confirmations for clients in the invited state. Client #{params['id']} is in another state.") or return unless client_session.status == "invited"

      client_session.invite_client
    end

    render json: {status: "resent"}, status: 200 and return

  end

  def get_session
    Session.find_by(api_token: params["id"]) || Session.find(params["id"])
  end

end
