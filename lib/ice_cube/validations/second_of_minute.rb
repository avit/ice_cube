module IceCube

  module Validations::SecondOfMinute

    def second_of_minute(*seconds)
      seconds.flatten.each do |second|
      unless second.is_a?(Fixnum)
        raise ArgumentError, "Expecting Fixnum value for second, got #{second.inspect}"
      end
        validations_for(:second_of_minute) << Validation.new(second)
      end
      clobber_base_validations :sec
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :second
      alias :value :second

      def initialize(second)
        @second = second
      end

      def type
        :sec
      end

      def accept(builder)
        builder.add_second_of_minute(self)
      end

      def build_hash(builder)
        builder.validations_array(:second_of_minute) << second
      end

      def build_ical(builder)
        builder['BYSECOND'] << second
      end

    end

  end

end
