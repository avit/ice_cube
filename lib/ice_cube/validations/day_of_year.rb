module IceCube

  module Validations::DayOfYear

    def day_of_year(*days)
      days.flatten.each do |day|
        unless day.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for day, got #{day.inspect}"
        end
        validations_for(:day_of_year) << Validation.new(day)
      end
      clobber_base_validations(:month, :day, :wday)
      self
    end

    class Validation

      attr_reader :day

      def initialize(day)
        @day = day
      end

      def type
        :day
      end

      def validate(step_time, schedule)
        days_in_year = TimeUtil.days_in_year(step_time)
        yday = day < 0 ? day + days_in_year : day
        offset = yday - step_time.yday
        offset >= 0 ? offset : offset + days_in_year
      end

      def accept(builder)
        builder.add_day_of_year(self)
      end

      def build_hash(builder)
        builder.validations_array(:day_of_year) << day
      end

      def build_ical(builder)
        builder['BYYEARDAY'] << day
      end

    end

  end

end
