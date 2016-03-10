module Dry
  module Validation
    class Error
      include Dry::Equalizer(:name, :result)

      attr_reader :name, :result

      def initialize(name, result)
        @name = name
        @result = result
      end

      def schema?
        result.response.is_a?(Validation::Result)
      end

      def to_ast
        node = [:error, [name, result.to_ast]]
        schema? ? [:schema, node] : node
      end
    end
  end
end
