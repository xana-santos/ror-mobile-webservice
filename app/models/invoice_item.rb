class InvoiceItem < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  include RecordTokenable
  include IdentityCache
  include ActsAsGraphable
  include Taxable
  
  acts_as_paranoid
  
  cache_index :api_token, unique: true
  
  belongs_to :record, polymorphic: true
  
  belongs_to :invoice
  
  before_save :set_fees
  
  scope :without_shipping, -> { where.not(item: "Shipping Fee") }
    
  scope :daily_charges, -> { 
    range = (Date.today-7.days)..Date.today
    charges = all.group_by_day(:created_at, format: "%d %b %Y").where(created_at: range).sum(:total)
    range.map {|date| charges[date.strftime("%d %b %Y")]/100.00 rescue 0}
  }
  
  scope :weekly_charges, -> { 
    range = (Date.today-1.month)..Date.today
    charges = all.group_by_week(:created_at, format: "%U %Y").where(created_at: range).sum(:total)
    ranges = range.map{|date| date.strftime("%U %Y")}.uniq
    ranges.map {|date| charges[date]/100.00 rescue 0}
  }

  scope :monthly_charges, -> { 
    range = (Date.today-1.year)..Date.today
    charges = all.group_by_month(:created_at, format: "%b").where(created_at: range).sum(:total)
    ranges = range.map{|date| date.strftime("%b")}.uniq
    ranges.map {|date| charges[date]/100.00 rescue 0}
  }
    
  def set_fees
    self.fees = (total.to_i - subtotal.to_i)
  end
  
  def description
    "#{quantity} x #{item} at #{number_to_currency(subtotal_dollars)}"
  end
  
  def subtotal_dollars
    subtotal/100.00
  end

  def total_dollars
    total/100.00
  end
  
  def subtotal_ex_gst
    (subtotal_dollars*ex_gst_multiplier).round(2)
  end
  
  def subtotal_gst
    (subtotal_dollars*Settings.fees.gst_percent).round(2)
  end
  
  def fees_dollars
    fees/100.00
  end
  
  def fees_ex_gst
    (fees_dollars*(1-Settings.fees.gst_percent)).round(2)
  end
  
  def fees_gst
    (fees_dollars*Settings.fees.gst_percent).round(2)
  end

end
