class ActiveRecord::Base
  include TokenGenerator
  include Syncable
  delegate :url_helpers, to: 'Rails.application.routes'
end

class Fibonacci
  
  # :nocov:
  def get(index=1)
    Hash.new{ |h,k| h[k] = k < 2 ? k : h[k-1] + h[k-2] }[index]
  end
  # :nocov:
  
end

module ToBoolean
  def to_bool
    return true if self == true || self.to_s.strip =~ /^(true|yes|y|1)$/i
    return false
  end
end

class NilClass; include ToBoolean; end
class TrueClass; include ToBoolean; end
class FalseClass; include ToBoolean; end
class Numeric; include ToBoolean; end
class String; include ToBoolean; end

class Numeric
  include ActionView::Helpers::NumberHelper
  
  def precision(amount)
    number_with_precision(self, precision: amount)
  end
  
  def negate
    self*-1
  end
  
end