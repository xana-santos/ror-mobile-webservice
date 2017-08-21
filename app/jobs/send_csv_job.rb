class SendCsvJob < Struct.new(:trainer, :filters)
  
  #:nocov:
  def perform
    invoices = trainer.invoices.by_date(filters["start_date"], filters["end_date"])
    UserMailer.csv_email(trainer, invoices.as_csv).deliver
  end
  
  def error(job, exception)
    
  end

  def reschedule_at(time, attempts)
    time + (Fibonacci.new.get(attempts)).minutes
  end
  
  def failure_details
    {
      "Error" => "Failed to send a CSV."
    }
  end

  def max_attempts
    5
  end
  #:nocov:
  
end