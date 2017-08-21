module Taxable
  extend ActiveSupport::Concern

    def gst_multiplier
      1+Settings.fees.gst_percent
    end
    
    def ex_gst_multiplier
      1-Settings.fees.gst_percent
    end
    
end
  
  