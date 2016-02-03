require 'dry/validation/error_compiler'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler
      attr_reader :rules, :excluded

      EXCLUDED = [:none?].freeze

      class Input < ErrorCompiler::Input
        attr_reader :excluded

        def initialize(messages, options)
          super
          @excluded = options.fetch(:excluded)
        end

        def visit_predicate(node)
          predicate, _ = node

          return {} if excluded.include?(predicate)

          super.each_with_object({}) { |(name, msgs), result|
            result[name] = msgs[0]
          }
        end
      end

      def initialize(messages, options = {})
        super
        @rules = @options.delete(:rules)
        @excluded = @options.fetch(:excluded, EXCLUDED)
      end

      def with(new_options)
        super(new_options.merge(rules: rules))
      end

      def call
        super(rules)
      end

      def visit_or(node)
        left, right = node
        merge([visit(left), visit(right)])
      end

      def visit_and(node)
        _, right = node
        visit(right)
      end

      def visit_implication(node)
        _, right = node
        visit(right)
      end

      def visit_val(node)
        name, predicate = node
        input_visitor(name).visit(predicate)
      end

      def input_visitor(name)
        HintCompiler::Input.new(
          messages, options.merge(name: name, input: nil, excluded: excluded)
        )
      end

      private

      def method_missing(*)
        {}
      end
    end
  end
end
