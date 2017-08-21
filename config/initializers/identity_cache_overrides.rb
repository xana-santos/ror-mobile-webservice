require 'dalli-delete-matched'

IdentityCache::FallbackFetcher.module_eval do
  
  # :nocov:
  def delete(key)
    @cache_backend.delete_matched(key)
  end
  # :nocov:
  
end