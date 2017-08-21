module TokenGenerator
  extend ActiveSupport::Concern
  
  included do
    after_create :generate_api_token
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
  end

  def generate_api_token
    if self.has_attribute?(:api_token) && api_token.blank?
      generate_token(:api_token)
      save!
    end
  end
  
end