module IceCube

  module Validations::MonthOfYear

    def month_of_year(*months)
      months.flatten.each do |month|
        unless month.is_a?(Fixnum) || month.is_a?(Symbol)
          raise ArgumentError, "expecting Fixnum or Symbol value for month, got #{month.inspect}"
        end
        month = TimeUtil.sym_to_month(month)
        validations_for(:month_of_year) << Validation.new(month)
      end
      clobber_base_validations :month
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :month
      alias :value :month

      def initialize(month)
        @month = month
      end

      def type
        :month
      end

      def accept(builder)
        builder.add_month_of_year(self)
      end

      def build_hash(builder)
        builder.validations_array(:month_of_year) << month
      end

      def build_ical(builder)
        builder['BYMONTH'] << month
      end

    end

  end

end
