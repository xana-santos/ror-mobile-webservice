class ClientDetailSerializer < BaseSerializer
  attributes :start_date, :supplement_only, :prospect_only, :session_rate, :session_duration, :num_bulk_sessions

  def start_date
    object.start_date.strftime("%Y-%m-%d") rescue nil
  end

  cached

  self.version = 1

  def cache_key
    self.class.cache_key << "#{object.id}-#{@options[:show_deleted] ? 'with-deleted' : 'without-deleted'}-#{object.updated_at.to_i}"
  end

end
