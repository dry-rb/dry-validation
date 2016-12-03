require 'dry/equalizer'

module Dry
  module Validation
    class Result
      include Dry::Equalizer(:output, :errors)
      include Enumerable

      attr_reader :output
      attr_reader :results
      attr_reader :message_compiler
      attr_reader :path

      alias_method :to_hash, :output
      alias_method :to_h, :output # for MRI 2.0, remove it when drop support

      def initialize(output, results, message_compiler, path)
        @output = output
        @results = results
        @message_compiler = message_compiler
        @path = path
      end

      def each(&block)
        output.each(&block)
      end

      def [](name)
        output.fetch(name)
      end

      def success?
        results.empty?
      end

      def failure?
        !success?
      end

      def messages(options = EMPTY_HASH)
        message_set(options).dump
      end

      def errors(options = EMPTY_HASH)
        message_set(options.merge(hints: false)).dump
      end

      def hints(options = EMPTY_HASH)
        message_set(options.merge(failures: false)).dump
      end

      def message_set(options = EMPTY_HASH)
        message_compiler.with(options).(result_ast)
      end

      def to_ast
        if name
          [type, [name, [:set, result_ast]]]
        else
          ast
        end
      end

      def ast(*)
        [:set, result_ast]
      end

      def name
        Array(path).last
      end

      private

      def type
        success? ? :success : :failure
      end

      def result_ast
        @result_ast ||= results.map(&:to_ast)
      end
    end
  end
end
