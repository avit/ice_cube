module IceCube

  module Validations::SecondlyInterval

    def interval(interval)
      @interval = interval
      replace_validations_for(:interval, [Validation.new(interval)])
      clobber_base_validations(:sec)
      self
    end

    class Validation

      attr_reader :interval

      def initialize(interval)
        @interval = interval
      end

      def type
        :sec
      end

      def dst_adjust?
        false
      end

      def validate(step_time, schedule)
        seconds = step_time.to_i - schedule.start_time.to_i
        offset = (seconds % interval).nonzero?
        interval - offset if offset
      end

      def accept(builder)
        builder.add_secondly_interval(self)
      end

      def build_hash(builder)
        builder[:interval] = interval
      end

      def build_ical(builder)
        builder['FREQ'] << 'SECONDLY'
        builder['INTERVAL'] << interval unless interval == 1
      end

    end

  end

end
