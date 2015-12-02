module Dry
  module Validation
    class Schema::Result
      include Dry::Equalizer(:params, :messages)
      include Enumerable

      attr_reader :params

      attr_reader :result

      attr_reader :errors

      attr_reader :error_compiler

      def initialize(params, result, errors, error_compiler)
        @params = params
        @result = result
        @errors = errors
        @error_compiler = error_compiler
      end

      def each(&block)
        failures.each(&block)
      end

      def empty?
        errors.empty?
      end

      def to_ary
        errors.map(&:to_ary)
      end

      def messages
        @messages ||= error_compiler.(errors.map(&:to_ary))
      end

      def successes
        result.select(&:successes?)
      end

      def failures
        result.select(&:failure?)
      end
    end
  end
end
