module Dry
  module Validation
    class Error
      include Dry::Equalizer(:name, :result)

      attr_reader :name, :result

      def initialize(name, result)
        @name = name
        @result = result
      end

      def messages(compiler)
        msg_hash = compiler.visit(to_ast)

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
