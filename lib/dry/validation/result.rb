module Dry
  module Validation
    def self.Result(input)
      case input
      when Result then input
      else Result.new(input)
      end
    end

    class Result
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def success?
        @value
      end

      def failure?
        ! success?
      end

      def &(other)
        if failure?
          self
        else
          other
        end
      end
    end
  end
end
