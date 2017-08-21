class Appointment < ActiveRecord::Base
  include Repeatable

  acts_as_paranoid

  has_many :client_appointments
  has_many :appointment_clients, through: :client_appointments, source: :client
  belongs_to :trainer

  has_one :gym, through: :trainer
  has_one :gym_location, through: :trainer

  has_many :sessions, dependent: :destroy
  has_many :client_sessions, through: :sessions

  validates :api_token, :id, uniqueness: true

  attr_accessor :clients

  scope :by_time, -> (start_time=nil, end_time=nil){ starting_from(start_time).ending_by(end_time) }
  scope :starting_from, -> (start_time){ start_time.blank? ? all : where("start_date >= ? AND start_time >= ?", start_time["date"], start_time["time"]) }
  scope :ending_by, -> (end_time){ end_time.blank? ? all : where("end_date <= ? AND end_time <= ?", end_time["date"], end_time["time"]) }
  scope :by_associations, -> (filters={}){ by_trainer(filters["trainer_id"]).by_client(filters["client_id"]) }
  scope :by_trainer, -> (trainer){ trainer.blank? ? all : joins(:trainer).where(users: {api_token: trainer}) }
  scope :by_client, -> (client){ client.blank? ? all : joins(:client_appointments).joins("INNER JOIN users clients ON clients.id = client_appointments.client_id AND clients.type IN ('Client')").where(clients: {api_token: client}) }
  scope :starting_near, -> (session_time){ includes(:sessions).where("next_session at time zone 'UTC' <= ? AND (NOT EXISTS (SELECT 1 from sessions where sessions.utc_datetime = next_session AND sessions.deleted_at IS NULL))", session_time).references(:sessions) }

  after_save :associate_clients
  before_destroy :cancel_existing

  def cancel_existing
    client_sessions.joins(:session).where("sessions.utc_datetime > ?", DateTime.current.utc).where(client_sessions: {status: ["invited", "confirmed"]}).each{|cs| cs.update_attributes(status: "cancelled")}
  end

  def associate_clients
    unless clients.blank?

      client_appointments.joins(:client).where.not(users: {api_token: clients}).destroy_all
      existing_tokens = appointment_clients.pluck(:api_token)

      (clients - existing_tokens).each do |c|
        client = Client.find_by(api_token: c)
        client_appointments.create!(client: client) unless client.blank?
      end
    end
  end

  def delete_day(day_to_delete)
    if start_date === end_date
      # Assume day_to_delete would be either start or end date
      self.destroy
      return nil
    end

    if start_date < Date.parse(day_to_delete) && end_date > Date.parse(day_to_delete)
      after_delete_app = self.dup

      after_delete_app.api_token = nil

      self.end_date = (Date.parse(day_to_delete) - 1.day).to_s
      after_delete_app.start_date = (Date.parse(day_to_delete) + 1.day).to_s

      after_delete_app.save
    else
      # ap "day deleted at the start"
      self.start_date = (Date.parse(day_to_delete) + 1.day).to_s if Date.parse(day_to_delete) === self.start_date
      self.end_date = (Date.parse(day_to_delete) - 1.day).to_s if Date.parse(day_to_delete) === self.end_date
    end
    self.save
    api_token
  end

  def set_next_session_date
    self.update_attributes(next_session: calculate_next_date(self.repeat_after, self.sessions.last.date))
  end

  private

  def calculate_next_date(repeat_after, last_session_date)
    next_date = last_session_date
    # 2037-12-31 is the default end date for recurrence gem
    end_date = self.end_date || Date.new(2036,12,31)
    if repeat_after.eql? "day"
      next_date = next_date + 1.day if (last_session_date + 1.day) < end_date
    elsif repeat_after.eql? "week"
      next_date = next_date + 1.week if (last_session_date + 1.week) < end_date
    elsif repeat_after.eql? "fortnight"
      next_date = next_date + 2.week if (last_session_date + 2.week) < end_date
    elsif repeat_after.eql? "month"
      next_date = next_date + 1.month if (last_session_date + 1.month) < end_date
    else
      next_date = nil
    end
    next_date
  end
end
