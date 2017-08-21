class SmsSender
  def initialize
    @client = Twilio::REST::Client.new
  end

  def send(sms_props)
    begin
      @client.account.messages.create sms_props.merge(from: Settings.twilio.number)
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end
end