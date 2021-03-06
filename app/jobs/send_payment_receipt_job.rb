class SendPaymentReceiptJob < Struct.new(:invoice)
  
  #:nocov:
  def perform
    UserMailer.payment_email(invoice).deliver
  end
  
  def error(job, exception)
    
  end

  def reschedule_at(time, attempts)
    time + (Fibonacci.new.get(attempts)).minutes
  end
  
  def failure_details
    {
      "Error" => "Failed to send payment receipt"
    }
  end

  def max_attempts
    5
  end
  #:nocov:
  
end