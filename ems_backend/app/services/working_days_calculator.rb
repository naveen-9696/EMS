module WorkingDaysCalculator
  def self.working_day?(date)
    date = date.to_date

    holidays = PUBLIC_HOLIDAYS.fetch(date.year, [])

    !date.sunday? && !holidays.include?(date)
  end

  def self.working_dates(start_date, end_date)
    start_date = Date.parse(start_date.to_s)
    end_date = Date.parse(end_date.to_s)

    return [] if end_date < start_date

    (start_date..end_date).select do |date|
      working_day?(date)
    end
  end

  def self.working_days_count(start_date, end_date)
    working_dates(start_date, end_date).count
  end
end
