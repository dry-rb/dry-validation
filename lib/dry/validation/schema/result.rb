module Dry
  module Validation
    class Schema::Result
      include Dry::Equalizer(:output, :messages)

      attr_reader :output

      attr_reader :result

      attr_reader :errors

      EMPTY_MESSAGES = {}.freeze

      def initialize(output, result, errors)
        @output = output
        @result = result
        @errors = errors
      end

      def [](name)
        result[name]
      end

      def success?
        errors.empty?
      end

      def failure?
        !success?
      end

      def messages(options = {})
        @messages ||= errors
          .map { |error| error.messages(options) }
          .reduce(:merge) || EMPTY_MESSAGES
      end

      def to_ast
        [:set, errors.map(&:to_ast)]
      end

      def successes
        result.successes
      end

      def failures
        result.failures
      end
    end
  end
end
