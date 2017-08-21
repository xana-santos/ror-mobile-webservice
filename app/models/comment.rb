class Comment < ActiveRecord::Base
  include IdentityCache
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  
  belongs_to :client
  delegate :trainer, to: :client
  
  cache_has_one :client, embed: true, inverse_name: :comments
    
end
