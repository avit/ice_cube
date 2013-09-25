module IceCube

  class StringBuilder

    NUMBER_SUFFIX = ['th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th']
    SPECIAL_SUFFIX = { 11 => 'th', 12 => 'th', 13 => 'th', 14 => 'th' }
    FORMATTERS = Hash.new

    def initialize(root)
      @nodes = Hash.new { |h, k|  h[k] = [] }
      root.accept(self)
      yield self if block_given?
    end

    def to_s
      @nodes.each_with_object(format(*@root)) do |(type, segments), str|
        str << ' ' << format(type, segments)
      end
    end

    def add_schedule(schedule)
      @root = :schedule, schedule
    end

    def add_daily_interval(val)
      @root = :daily_interval, val.interval
    end

    def add_hourly_interval(val)
      @root = :hourly_interval, val.interval
    end

    def add_minutely_interval(val)
      @root = :minutely_interval, val.interval
    end

    def add_monthly_interval(val)
      @root = :monthly_interval, val.interval
    end

    def add_secondly_interval(val)
      @root = :secondly_interval, val.interval
    end

    def add_weekly_interval(val)
      @root = :weekly_interval, val.interval
    end

    def add_yearly_interval(val)
      @root = :yearly_interval, val.interval
    end

    def add_count(val)
      @nodes[:count] = val.count
    end

    def add_until(val)
      @nodes[:until] = val.time
    end

    def add_day(val)
      @nodes[:day] << val.day
    end

    def add_day_of_month(val)
      @nodes[:day_of_month] << val.day
    end

    def add_day_of_week(val)
      @nodes[:day_of_week] << [val.occ, val.day]
    end

    def add_day_of_year(val)
      @nodes[:day_of_year] << val.day
    end

    def add_hour_of_day(val)
      @nodes[:hour_of_day] << val.hour
    end

    def add_minute_of_hour(val)
      @nodes[:minute_of_hour] << val.minute
    end

    def add_month_of_year(val)
      @nodes[:month_of_year] << val.month
    end

    def add_second_of_minute(val)
      @nodes[:second_of_minute] << val.second
    end

    def format(type, value)
      if not FORMATTERS[type].respond_to?(:call)
        raise ArgumentError, "#{type} is not a callable formatter"
      end
      instance_exec(value, &FORMATTERS[type])
    end

    def self.register_formatter(type, &formatter)
      if not formatter.respond_to?(:call)
        raise ArgumentError, "#{type} is not a callable formatter"
      end
      FORMATTERS[type] = formatter
    end

    register_formatter :day do |entries|
      case entries = entries.sort
      when [0, 6]          then 'on Weekends'
      when [1, 2, 3, 4, 5] then 'on Weekdays'
      else
        "on " << format(:sentence, format(:daynames, entries))
      end
    end

    register_formatter :dayname do |number|
      Date::DAYNAMES[number]
    end

    register_formatter :daynames do |entries|
      entries.map { |wday| format(:dayname, wday) + "s" }
    end

    register_formatter :monthnames do |entries|
      entries.map { |m| Date::MONTHNAMES[m] }
    end

    register_formatter :count do |number|
      times = number == 1 ? "time" : "times"
      "#{number} #{times}"
    end

    register_formatter :day_of_month do |entries|
      numbered = format(:sentence, format(:ordinals, entries))
      days = entries.size == 1 ? "day" : "days"
      "on the #{numbered} #{days} of the month"
    end

    register_formatter :day_of_week do |entries|
      numbered_weekdays = format(:daynames_of_week, entries).join(" and ")
      "on the #{numbered_weekdays}"
    end

    register_formatter :daynames_of_week do |entries|
      entries.map do |occurrence, wday|
        numbered = format(:ordinal, occurrence)
        weekday  = format(:dayname, wday)
        "#{numbered} #{weekday}"
      end
    end

    register_formatter :day_of_year do |entries|
      numbered = format(:sentence, format(:ordinals, entries))
      days = entries.size == 1 ? "day" : "days"
      "on the #{numbered} #{days} of the year"
    end

    register_formatter :hour_of_day do |entries|
      numbered = format(:sentence, format(:ordinals, entries))
      hours = entries.size == 1 ? "hour" : "hours"
      "on the #{numbered} #{hours} of the day"
    end

    register_formatter :minute_of_hour do |entries|
      numbered = format(:sentence, format(:ordinals, entries))
      minutes = entries.size == 1 ? "minute" : "minutes"
      "on the #{numbered} #{minutes} of the hour"
    end

    register_formatter :month_of_year do |entries|
      "in " << format(:sentence, format(:monthnames, entries))
    end

    register_formatter :second_of_minute do |entries|
      numbered = format(:sentence, format(:ordinals, entries))
      seconds = entries.size == 1 ? "second" : "seconds"
      "on the #{numbered} #{seconds} of the minute"
    end

    register_formatter :time do |time|
      time.strftime(IceCube.to_s_time_format)
    end

    register_formatter :until do |time|
      "until " << format(:time, time)
    end

    register_formatter :sentence do |entries|
      case entries.length
      when 0 then ''
      when 1 then entries[0].to_s
      when 2 then "#{entries[0]} and #{entries[1]}"
      else "#{entries[0...-1].join(', ')}, and #{entries[-1]}"
      end
    end

    register_formatter :ordinals do |entries|
      entries = entries.sort
      entries.rotate! while entries[0] < 0 if entries.last > 0
      entries.map { |number| format(:ordinal, number) }
    end

    register_formatter :ordinal do |number|
      next "last" if number == -1
      suffix = SPECIAL_SUFFIX[number] || NUMBER_SUFFIX[number.abs % 10]
      if number < -1
        number.abs.to_s << suffix << " to last"
      else
        number.to_s << suffix
      end
    end

    register_formatter :daily_interval do |i|
      i == 1 ? "Daily" : "Every #{i} days"
    end

    register_formatter :hourly_interval do |i|
      i == 1 ? "Hourly" : "Every #{i} hours"
    end

    register_formatter :minutely_interval do |i|
      i == 1 ? "Minutely" : "Every #{i} minutes"
    end

    register_formatter :monthly_interval do |i|
      i == 1 ? "Monthly" : "Every #{i} months"
    end

    register_formatter :secondly_interval do |i|
      i == 1 ? "Secondly" : "Every #{i} seconds"
    end

    register_formatter :weekly_interval do |i|
      i == 1 ? "Weekly" : "Every #{i} weeks"
    end

    register_formatter :yearly_interval do |i|
      i == 1 ? "Yearly" : "Every #{i} years"
    end

    register_formatter :schedule do |s|
      times = s.recurrence_times_with_start_time - s.extimes
      pieces = []
      pieces.concat times.uniq.sort.map     { |t| format(:time, t) }
      pieces.concat s.rrules.map            { |t| t.to_s }
      pieces.concat s.exrules.map           { |t| "not #{t.to_s}" }
      pieces.concat s.extimes.uniq.sort.map { |t| "not on #{format(:time, t)}" }
      pieces.join(' / ')
    end

  end
end
