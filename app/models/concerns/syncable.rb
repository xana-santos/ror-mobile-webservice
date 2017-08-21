module Syncable
  extend ActiveSupport::Concern

  module ClassMethods

    def filtered(params={})
      offset = params[:offset] || 0
      limit = params[:limit] || 25
      remove_limit = (params[:remove_limit].to_bool || false)
      timestamp = params[:timestamp].to_i || 0
      start_time = params[:start]
      end_time = params[:end]
      include_deleted = (params[:include_deleted].to_bool || false)

      if include_deleted && remove_limit
        all.with_deleted.offset(offset).by_timestamp(timestamp)
      elsif include_deleted && !remove_limit
        all.with_deleted.limit(limit).offset(offset).by_timestamp(timestamp)
      elsif !include_deleted && remove_limit
        all.offset(offset).by_timestamp(timestamp)
      elsif !include_deleted && !remove_limit
        all.limit(limit).offset(offset).by_timestamp(timestamp)
      end

      # unless include_deleted
      #   all.limit(limit).offset(offset).by_timestamp(timestamp)
      # else
      #   all.with_deleted.limit(limit).offset(offset).by_timestamp(timestamp)
      # end

    end

    def by_timestamp(timestamp)
      where("#{self.table_name}.updated_at >= ?", Time.at(timestamp))
    end

  end

end
