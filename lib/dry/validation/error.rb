module Dry
  module Validation
    class Error
      include Dry::Equalizer(:name, :result)

      attr_reader :name, :result, :error_compiler, :hint_compiler

      def initialize(name, result, error_compiler, hint_compiler)
        @name = name
        @result = result
        @error_compiler = error_compiler
        @hint_compiler = hint_compiler
      end

      def messages(options = {})
        hints = hint_compiler.with(options).call
        msg_hash = error_compiler.with(options.merge(hints: hints)).([to_ast])

        if msg_hash.key?(name) || name != result.name
          msg_hash
        else
          { name => msg_hash }
        end
      end

      def to_ast
        [:error, [name, result.to_ast]]
      end
    end
  end
end
