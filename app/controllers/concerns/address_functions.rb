module AddressFunctions
  extend ActiveSupport::Concern 
  
  private
  
  def check_main_address(address, client=address.record)
    show_errors("Client already has a main address. Please remove or update this address first.") and return if !client.main_address.blank? && address.main_address
    return true
  end
   
end