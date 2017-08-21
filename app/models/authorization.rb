class Authorization < ActiveRecord::Base
  
  before_create :generate_access_token
  
  private

  def generate_access_token
     self.auth_token = SecureRandom.hex(38) unless self.auth_token.present?
  end
  
end
