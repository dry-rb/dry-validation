module Dry
  module Validation
    def self.Result(input, value)
      Result.new(input, value)
    end

    class Result
      attr_reader :input, :value

      def initialize(input, value)
        @input = input
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
