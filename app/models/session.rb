class Session < ActiveRecord::Base
  acts_as_paranoid
  include Repeatable
  # include IdentityCache

  attr_accessor :status

  # cache_index :api_token, unique: true

  belongs_to :appointment, touch: true

  has_many :client_sessions, dependent: :destroy
  has_many :clients, through: :client_sessions
  has_many :appointment_clients, through: :appointment

  has_one :trainer, through: :appointment

  has_one :gym_location, through: :trainer
  has_one :gym, through: :trainer

  has_many :invoices, through: :client_sessions
  has_many :invoice_items, through: :invoice_items

  before_save :set_utc_datetime, if: :datetime_changes?

  accepts_nested_attributes_for :client_sessions

  scope :by_associations, -> (filters={}){ by_appointment(filters["appointment_id"]).by_client(filters["client_id"]).by_trainer(filters["trainer_id"]) }

  scope :by_appointment, -> (appointment){ appointment.blank? ? all : joins(:appointment).where(appointments: {api_token: appointment}) }
  scope :by_client, -> (client){ client.blank? ? all : joins(:clients).where(users: {api_token: client}) }
  scope :by_trainer, -> (trainer){ trainer.blank? ? all : joins(:appointment).joins("INNER JOIN users trainers ON trainers.id = appointments.trainer_id AND trainers.type IN ('Trainer')").where(trainers: {api_token: trainer}) }

  scope :by_time, -> (start_time=nil, end_time=nil){ starting_from(start_time).ending_by(end_time) }

  scope :starting_from, -> (start_time){ start_time.blank? ? all : starting_date_from(start_time["date"]).starting_time_from(start_time["time"]) }
  scope :ending_by, -> (end_time){ end_time.blank? ? all : ending_date_from(end_time["date"]).ending_time_from(end_time["time"]) }

  scope :starting_date_from, -> (date){ date.blank? ? all : where("date >= ?", date) }
  scope :starting_time_from, -> (time){ time.blank? ? all : where("time >= ?", time) }

  scope :ending_date_from, -> (date){ date.blank? ? all : where("date <= ?", date) }
  scope :ending_time_from, -> (time){ time.blank? ? all : where("time <= ?", time) }

  after_create :add_session_rate
  after_save :check_status, if: -> (session){ !session.status.blank? } 

  before_save :check_time
  before_save :set_utc_datetime, if: :datetime_changes?

  delegate :duration, to: :appointment

  def add_session_rate
    if session_rate.present?
      update_attributes(session_rate: session_rate)
    else
      update_attributes(session_rate: appointment.session_rate)
    end
  end

  def reject!
    # ap "Reject! is called"
    set_client_status("cancelled")
  end

  def set_client_status(status)
    # ap "Set client status with status=#{status}"

    client_sessions.each{|cs| cs.update_attributes!(status: status) }
  end

  def set_utc_datetime
    self.utc_datetime = self.get_utc_datetime(date, time)
  end

  def datetime_changes?
    date_changed? || time_changed?
  end

  def cancellable?
    utc_datetime > DateTime.current.utc
  end

  def create_client_sessions(status="confirmed")
    client_session_attributes = appointment_clients.map{|c| {client: c, status: status}}
    update_attributes(client_sessions_attributes: client_session_attributes)
  end

  def check_status
    
    if appointment.event_type == "appointment"
      client_sessions.blank? ? create_client_sessions("confirmed") : set_client_status(status)
    end
  end

  def status
    client_sessions.select {|cs| cs.status.eql? "cancelled"}.empty? ? "confirmed" : "cancelled"
  end

  def check_time
    self.time = appointment.start_time if self.time.blank?
  end

end
