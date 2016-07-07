require 'dry/validation/message_compiler'

module Dry
  module Validation
    class HintCompiler < MessageCompiler
      include Dry::Equalizer(:messages, :rules, :options)

      attr_reader :rules, :excluded, :cache

      TYPES = {
        none?: NilClass,
        bool?: TrueClass,
        str?: String,
        int?: Fixnum,
        float?: Float,
        decimal?: BigDecimal,
        date?: Date,
        date_time?: DateTime,
        time?: Time,
        hash?: Hash,
        array?: Array
      }.freeze

      EXCLUDED = (%i(key? none? filled?) + TYPES.keys).freeze

      def self.cache
        @cache ||= Concurrent::Map.new
      end

      def initialize(messages, options = {})
        super(messages, options)
        @rules = options.fetch(:rules, EMPTY_ARRAY)
        @excluded = options.fetch(:excluded, EXCLUDED)
        @cache = self.class.cache
      end

      def message_type
        :hint
      end

      def message_class
        Hint
      end

      def hash
        @hash ||= [messages, rules, options].hash
      end

      def call
        cache.fetch_or_store(hash) { super(rules) }
      end

      def visit_predicate(node, opts = EMPTY_HASH)
        predicate, args = node
        return EMPTY_ARRAY if excluded.include?(predicate) || dyn_args?(args)
        super(node, opts.merge(val_type: TYPES[predicate]))
      end

      def visit_each(node, opts = EMPTY_HASH)
        visit(node, opts.merge(each: true))
      end

      def visit_or(node, *args)
        left, right = node
        [Array[visit(left, *args)], Array[visit(right, *args)]].flatten
      end

      def visit_and(node, *args)
        _, right = node
        visit(right, *args)
      end

      def visit_schema(node, opts = EMPTY_HASH)
        path = node.config.path
        rules = node.rule_ast
        schema_opts = opts.merge(path: [path])

        rules.map { |rule| visit(rule, schema_opts) }
      end

      def visit_check(node)
        EMPTY_ARRAY
      end

      def visit_xor(node)
        EMPTY_ARRAY
      end

      def visit_not(node)
        EMPTY_ARRAY
      end

      def visit_type(node, *args)
        visit(node.rule.to_ast, *args)
      end

      private

      def dyn_args?(args)
        args.map(&:last).any? { |a| a.is_a?(UnboundMethod) }
      end
    end
  end
end
