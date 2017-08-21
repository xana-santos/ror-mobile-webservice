module SmsSenderConcern
  extend ActiveSupport::Concern

  def send_sms(body)
    logger.info("___**** SEND SMS ***___")
    logger.info("#{body}")

    # TODO - this should be a delayed job and not swallow exceptions.
    sender = SmsSender.new
    sender.send to:   mobile,
                body: body
  end
end


