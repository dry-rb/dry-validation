module Dry
  module Validation
    class Schema::Result
      include Dry::Equalizer(:output, :messages)
      include Enumerable

      attr_reader :output

      attr_reader :result

      attr_reader :errors

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(output, result, errors, error_compiler, hint_compiler)
        @output = output
        @result = result
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
      end

      def each(&block)
        failures.each(&block)
      end

      def success?
        errors.empty?
      end

      def to_ary
        errors.map(&:to_ary)
      end

      def messages(options = {})
        @messages ||= compile_messages(options)
      end

      def successes
        result.successes
      end

      def failures
        result.failures
      end

      private

      def compile_messages(options)
        hints = hint_compiler.with(options).call
        error_compiler.with(options.merge(hints: hints)).(to_ary)
      end
    end
  end
end
