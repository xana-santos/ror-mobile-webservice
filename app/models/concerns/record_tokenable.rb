module RecordTokenable
  extend ActiveSupport::Concern

  included do
    after_save :set_record_token, if: -> (obj){ obj.record_type_changed? || obj.record_id_changed? }

    scope :by_record, -> (record_type, record_id){ by_record_type(record_type).by_record_id(record_id) }
    scope :by_record_type, -> (record_type){ record_type.blank? and all or where(record_type: record_type.classify) }
    scope :by_record_id, -> (record_id){ record_id.blank? and all or where(record_token: record_id) }
  end

  def set_record_token
    self.update_columns(record_token: record.api_token, updated_at: Time.now)
  end
end
