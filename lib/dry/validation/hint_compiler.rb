require 'dry/validation/error_compiler/input'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler::Input
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

      EXCLUDED = [:none?, :filled?, :key?].freeze

      DEFAULT_OPTIONS = { name: nil, input: nil, message_type: :hint }.freeze

      EMPTY_MESSAGES = {}.freeze

      def self.cache
        @cache ||= Concurrent::Map.new
      end

      def initialize(messages, options = {})
        super(messages, DEFAULT_OPTIONS.merge(options))
        @rules = @options.delete(:rules)
        @excluded = @options.fetch(:excluded, EXCLUDED)
        @val_type = options[:val_type]
        @cache = self.class.cache
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

      def visit_predicate(node)
        predicate, _ = node

        val_type = TYPES[predicate]

        return with(val_type: val_type) if val_type
        return EMPTY_MESSAGES if excluded.include?(predicate)

        super
      end

      def visit_set(node)
        result = node.map do |el|
          visit(el)
        end
        merge(result)
      end

      def visit_each(node)
        visit(node)
      end

      def visit_or(node)
        left, right = node
        merge([visit(left), visit(right)])
      end

      def visit_and(node)
        left, right = node

        result = visit(left)

        if result.is_a?(self.class)
          result.visit(right)
        else
          visit(right)
        end
      end

      def visit_implication(node)
        _, right = node
        visit(right)
      end

      def visit_key(node)
        key, predicate = node

        path =
          if name && (name.is_a?(Array) || name != key)
            [*name, key].uniq
          else
            key
          end

        with(name: path).visit(predicate)
      end
      alias_method :visit_attr, :visit_key

      def visit_val(node)
        visit(node)
      end

      def visit_schema(node)
        merge(node.rule_ast.map(&method(:visit)))
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

      def visit_type(node)
        visit(node.rule.to_ast)
      end

      private

      def merge(result)
        super(result.reject { |el| el.is_a?(self.class) })
      end
    end
  end
end
