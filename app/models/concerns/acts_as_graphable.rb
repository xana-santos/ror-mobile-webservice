module ActsAsGraphable
  extend ActiveSupport::Concern

  module ClassMethods

    def total_records_counts_array_in_past_n_days(range = 30.days)
      total_records = []
      counts =  self.group('Date(created_at)').count
      (range.ago.to_date..Date.today).each do |day|
        total_records.push((total_records.last || 0) + (counts[day] || 0))
      end
      total_records
    end

    def daily_records_counts_array_in_past_n_days(range = 30.days)
      counts = self.group('Date(created_at)').count
      (range.ago.to_date..Date.today).map {|date| counts[date] || 0}
    end

    def get_money_min_max(column)

      groups = self.where("#{self.table_name}.created_at >= ?", Time.now.beginning_of_month - 1.year).group_by{|t| t.created_at.beginning_of_month.strftime("%b")}

      highest = []
      lowest = []
      averages = []
      total = []

      Date::ABBR_MONTHNAMES[1..12].rotate(Time.now.month - 12).each do |month|

        if groups[month]
          selected_column = groups[month].map{|g| g.send(column).to_f / 100.00}

          high = selected_column.max
          low = selected_column.min
          sum = selected_column.inject{ |sum, el| sum + el }.to_f
          average = sum / selected_column.size

          highest << high
          lowest << low
          averages << average
          total << sum
        else
          highest << 0
          lowest << 0
          averages << 0
          total << 0
        end

      end

      {highest: highest, lowest: lowest, averages: averages, total: total}

    end

  end

end
