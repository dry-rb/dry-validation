require 'dry/validation/error_compiler/input'

module Dry
  module Validation
    class HintCompiler < ErrorCompiler::Input
      include Dry::Equalizer(:messages, :rules, :options)

      attr_reader :rules, :excluded

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

      def self.cache
        @cache ||= Concurrent::Map.new
      end

      def initialize(messages, options = {})
        super(messages, { name: nil, input: nil }.merge(options))
        @rules = @options.delete(:rules)
        @excluded = @options.fetch(:excluded, EXCLUDED)
        @val_type = options[:val_type]
      end

      def with(new_options)
        super(new_options.merge(rules: rules))
      end

      def call
        self.class.cache.fetch_or_store(hash) do
          super(rules)
        end
      end

      def visit_predicate(node)
        predicate, _ = node

        val_type = TYPES[predicate]

        return with(val_type: val_type) if val_type
        return {} if excluded.include?(predicate)

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
        name, predicate = node
        with(name: Array([*self.name, name])).visit(predicate)
      end
      alias_method :visit_attr, :visit_key

      def visit_val(node)
        visit(node)
      end

      def visit_schema(node)
        DEFAULT_RESULT
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

      private

      def merge(result)
        super(result.reject { |el| el.is_a?(self.class) })
      end
    end
  end
end
