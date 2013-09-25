module IceCube

  module Validations::Until

    extend Deprecated

    # Value reader for limit
    def until_time
      @until
    end
    deprecated_alias :until_date, :until_time

    def until(time)
      time = TimeUtil.ensure_time(time, true)
      @until = time
      replace_validations_for(:until, time.nil? ? nil : [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def type
        :limit
      end

      def validate(step_time, schedule)
        raise UntilExceeded if step_time > time
      end

      def accept(builder)
        builder.add_until(self)
      end

      def build_hash(builder)
        builder[:until] = TimeUtil.serialize_time(time)
      end

      def build_ical(builder)
        builder['UNTIL'] << IcalBuilder.ical_utc_format(time)
      end

    end

  end

end
