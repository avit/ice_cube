module IceCube

  module Validations::MinuteOfHour

    def minute_of_hour(*minutes)
      minutes.flatten.each do |minute|
        unless minute.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for minute, got #{minute.inspect}"
        end
        validations_for(:minute_of_hour) << Validation.new(minute)
      end
      clobber_base_validations(:min)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :minute
      alias :value :minute

      def initialize(minute)
        @minute = minute
      end

      def type
        :min
      end

      def accept(builder)
        builder.add_minute_of_hour(self)
      end

      def build_hash(builder)
        builder.validations_array(:minute_of_hour) << minute
      end

      def build_ical(builder)
        builder['BYMINUTE'] << minute
      end

    end

  end

end
