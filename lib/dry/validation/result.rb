module Dry
  module Validation
    class Result
      include Dry::Equalizer(:output, :messages)
      include Enumerable

      attr_reader :output
      attr_reader :errors
      attr_reader :error_compiler
      attr_reader :hint_compiler

      alias_method :to_hash, :output
      alias_method :to_h, :output # for MRI 2.0, remove it when drop support

      EMPTY_MESSAGES = {}.freeze

      def initialize(output, errors, error_compiler, hint_compiler)
        @output = output
        @errors = errors
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
      end

      def each(&block)
        output.each(&block)
      end

      def [](name)
        output.fetch(name)
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
            hash = error_compiler.with(options).(error_ast).with_hints!(hints).to_h
            hash.key?(nil) ? hash.values.flatten : hash
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
