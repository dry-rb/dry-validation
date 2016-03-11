module Dry
  module Validation
    class Result
      include Dry::Equalizer(:output, :messages)

      attr_reader :output
      attr_reader :errors
      attr_reader :error_compiler
      attr_reader :hint_compiler

      EMPTY_MESSAGES = {}.freeze

      def initialize(output, errors, error_compiler, hint_compiler)
        @output = output
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
      end

      def success?
        errors.empty?
      end

      def failure?
        !success?
      end

      def messages(options = {})
        @messages ||=
          begin
            return EMPTY_MESSAGES if success?

            hints = hint_compiler.with(options).call
            comp = error_compiler.with(options.merge(hints: hints))

            comp.(error_ast)
          end
      end

      def to_ast
        [:set, error_ast]
      end

      private

      def error_ast
        errors.map { |error| error.to_ast }
      end
    end
  end
end
