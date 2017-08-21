class ClientCard < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :client
end
