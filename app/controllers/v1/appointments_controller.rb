class V1::AppointmentsController < ApiController
  include AppointmentFunctions

  def create
    
    trainer = Trainer.find_by(api_token: params["trainer_id"])
    check_appointment_type(params) or return
    check_exists(trainer, "trainer") or return
    
    if !Appointment.with_deleted.find_by_id(params[:id]).present?
   
      appointment = trainer.appointments.new(params.except(:action, :controller, :trainer_id).permit!)
      appointment.save


      if ["appointment", "own_time", "consultation", "complimentary_session"].include?(appointment.event_type)
        RecurringAppointmentCreator.new(appointment).create_sessions
        
        appointment.set_next_session_date
      end

  end

    render json: appointment, root: false, status: 200
  end

  def show
    appointment = get_appointment
    check_exists appointment or return
    render json: appointment, root: false, status: 200
  end

  def index
    offset = params[:offset] || 0
    limit = params[:limit] || 25
    remove_limit = (params[:remove_limit].to_bool || false)
    appointments = ::Appointment.by_time(params["start"], params["end"]).by_associations(params)

    filtered = remove_limit ? appointments : appointments.filtered(params).order(created_at: :asc)

    metadata = {total: filtered.count, offset: offset.to_i, limit: limit.to_i, remove_limit: remove_limit.to_s}

    render json: filtered, root: "appointments", show_deleted: params[:include_deleted].to_bool, meta: metadata, status: 200 and return
  end

  def update
    puts "====in update appointment"
    appointment = get_appointment
    check_exists appointment or return
    check_update_appointment(params, appointment) or return
    appointment.update_attributes(params.except(:action, :controller, :id).permit!)
    if appointment.sessions.count > 0
      if appointment.sessions.count == 1 
        puts "there is only one child session, will update its date"
        appointment.sessions.each do |s|
          s.update_attributes(session_rate: params[:session_rate], time: params[:start_time], date: params[:start_date])
        end
      else
        appointment.sessions.each do |s|
          s.update_attributes(session_rate: params[:session_rate], time: params[:start_time])
        end
      end
      
    end

    render json: {status: "updated"}, status: 200
  end

  def destroy
    if params["id"]
      appointment = get_appointment
      check_exists appointment or return
      if appointment.get_utc_datetime(app.start_date, app.start_time) < DateTime.now.utc 
        appointment.sessions.each do |s|
          if s[:utc_datetime] > DateTime.now.utc 
            s.destroy
          end
        end
        appointment_sessions = appointment.sessions.order(utc_datetime: :asc)
        appointment.update_attributes(end_time: (Time.parse(appointment_sessions.last[:time]) + appointment.duration.minutes).to_s(:time), end_date: appointment_sessions.last[:date])
        appointment.update_attributes(start_time: appointment_sessions.first[:time], start_date: appointment_sessions.first[:date])
      else
        appointment.destroy
      end
      
    elsif params["ids"]
      get_appointments.destroy_all
    end

    render json: {status: "deleted"}, status: 200
  end

  def restore
    appointment = get_deleted_appointment

    check_exists appointment or return

    appointment.restore!

    render json: {status: "restored"}, status: 200
  end

  private

  def get_appointment
    Appointment.find_by(api_token: params["id"]) || Appointment.find(params["id"])
  end

  def get_deleted_appointment
    Appointment.only_deleted.find_by(api_token: params["id"]) || Appointment.only_deleted.find(params["id"])
  end

  def get_appointments
    Appointment.where(api_token: params["ids"])
  end
end
