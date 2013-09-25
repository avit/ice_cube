module IceCube

  module Validations::HourOfDay

    # Add hour of day validations
    def hour_of_day(*hours)
      hours.flatten.each do |hour|
        unless hour.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for hour, got #{hour.inspect}"
        end
        validations_for(:hour_of_day) << Validation.new(hour)
      end
      clobber_base_validations(:hour)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :hour
      alias :value :hour

      def initialize(hour)
        @hour = hour
      end

      def type
        :hour
      end

      def accept(builder)
        builder.add_hour_of_day(self)
      end

      def build_hash(builder)
        builder.validations_array(:hour_of_day) << hour
      end

      def build_ical(builder)
        builder['BYHOUR'] << hour
      end

    end

  end

end
