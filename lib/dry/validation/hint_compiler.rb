require 'dry/validation/error_compiler'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler
      attr_reader :messages, :rules, :options

      def initialize(messages, options = {})
        @messages = messages
        @options = Hash[options]
        @rules = @options.delete(:rules)
      end

      def with(new_options)
        super(new_options.merge(rules: rules))
      end

      def call
        messages = Hash.new { |h, k| h[k] = [] }

        rules.map { |node| visit(node) }.compact.each do |hints|
          name, msgs = hints
          messages[name].concat(msgs)
        end

        messages
      end

      def visit_or(node)
        left, right = node
        [visit(left), Array(visit(right)).flatten.compact].compact
      end

      def visit_and(node)
        left, right = node
        [visit(left), Array(visit(right)).flatten.compact].compact
      end

      def visit_val(node)
        name, predicate = node
        visit(predicate, name)
      end

      def visit_predicate(node, name)
        predicate_name, args = node

        lookup_options = options.merge(rule: name, arg_type: args[0].class)

        template = messages[predicate_name, lookup_options]
        predicate_opts = visit(node, args)

        return unless predicate_opts

        tokens = predicate_opts.merge(name: name)

        template % tokens
      end

      def visit_key(node)
        name, _ = node
        name
      end

      def visit_attr(node)
        name, _ = node
        name
      end

      def method_missing(name, *args)
        nil
      end
    end
  end
end
