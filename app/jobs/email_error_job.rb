class EmailErrorJob < Struct.new(:message, :backtrace, :request)
  
  def perform
    UserMailer.error_email(message, backtrace, request).deliver
  end
  
  def error(job, exception)
    
  end

  def reschedule_at(time, attempts)
    time + (Fibonacci.new.get(attempts)).minutes
  end
  
  def failure_details
    {
      "Error" => "Failed to email an error. How ironic."
    }
  end

  def max_attempts
    5
  end
  
end