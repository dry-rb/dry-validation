module Dry
  module Validation
    class HintCompiler < ErrorCompiler
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

      EMPTY_MESSAGES = {}.freeze

      def self.cache
        @cache ||= Concurrent::Map.new
      end

      def initialize(messages, options = {})
        super(messages, Hash[options])
        @rules = @options.delete(:rules)
        @excluded = @options.fetch(:excluded, EXCLUDED)
        @cache = self.class.cache
      end

      def message_type
        :hint
      end

      def hash
        @hash ||= [messages, rules, options].hash
      end

      def with(new_options)
        return self if new_options.empty?
        super(new_options.merge(rules: rules))
      end

      def call
        cache.fetch_or_store(hash) { super(rules) }
      end

      def visit_predicate(node, opts = {})
        predicate, _ = node
        return EMPTY_MESSAGES if excluded.include?(predicate)
        super(node, opts.update(hint: true, val_type: TYPES[predicate]))
      end

      def visit_set(node, *args)
        result = node.map do |el|
          visit(el, *args)
        end
        merge(result)
      end

      def visit_each(node, opts = {})
        visit(node, opts.update(each: true))
      end

      def visit_or(node, *args)
        left, right = node
        merge([visit(left, *args), visit(right, *args)])
      end

      def visit_and(node, *args)
        _, right = node
        visit(right, *args)
      end

      def visit_implication(node, *args)
        _, right = node
        visit(right, *args)
      end

      def visit_schema(node, opts = {})
        path = node.config.path
        rules = node.rule_ast
        schema_opts = opts.merge(path: [path])

        result = merge(rules.map { |rule| visit(rule, schema_opts) })

        if result.size > 0
          result
        else
          DEFAULT_RESULT
        end
      end

      def visit_check(node)
        DEFAULT_RESULT
      end

      def visit_xor(node)
        DEFAULT_RESULT
      end

      def visit_not(node)
        DEFAULT_RESULT
      end

      def visit_type(node, *args)
        visit(node.rule.to_ast, *args)
      end
    end
  end
end
