class Image < ActiveRecord::Base
  include IdentityCache
  include RankedModel
  
  cache_index :api_token, unique: true
  
  acts_as_paranoid
  
  belongs_to :record, polymorphic: true, touch: true
  
  #acts_as_list scope: [:record_id, :record_type]
  
  ranks :position, with_same: [:record_id, :record_type]
  
end
