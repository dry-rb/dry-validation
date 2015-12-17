module Dry
  module Validation
    class Schema::Result
      include Dry::Equalizer(:params, :messages)
      include Enumerable

      attr_reader :params

      attr_reader :result

      attr_reader :errors

      attr_reader :error_compiler

      attr_reader :hint_compiler

      def initialize(params, result, errors, error_compiler, hint_compiler)
        @params = params
        @result = result
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
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

      def messages(options = {})
        @messages ||=
          begin
            all_msgs = error_compiler.with(options).(errors.map(&:to_ary))
            hints = hint_compiler.with(options).call

            all_msgs.each do |(name, data)|
              data[0].concat(hints[name]).uniq!
            end

            all_msgs
          end
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
