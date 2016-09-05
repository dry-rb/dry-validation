require 'dry/validation/deprecations'

module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        include ::Dry::Validation::Deprecations

        INVALID_PREDICATES = {
          value: [],
          maybe: [:empty?, :none?],
          filled: [:empty?, :filled?],
        }.freeze

        attr_reader :name, :node, :type, :target, :deps, :options

        def initialize(node, options = {})
          @node = node
          @type = options.fetch(:type, :and)
          @deps = options.fetch(:deps, [])
          @name = options.fetch(:name)
          @target = options.fetch(:target)
          @options = options
        end

        def inspect
          to_ast.inspect
        end
        alias_method :to_s, :inspect

        def schema(other = nil, &block)
          schema = Schema.create_class(target, other, &block)

          if schema.config.type_specs
            target.type_map[name] = schema.type_map
          end

          rule = __send__(type, key(:hash?).and(key(schema)))
          add_rule(rule)
        end

        def schema?
          target.schema?
        end

        def registry
          target.registry
        end

        def type_map
          target.type_map
        end

        def type_map?
          target.type_map?
        end

        def required(*predicates)
          warn 'required is deprecated - use filled instead.'

          filled(*predicates)
        end

        def filled(*predicates, &block)
          left = ([key(:filled?)] + infer_predicates(predicates, :filled)).reduce(:and)

          rule =
            if block
              left.and(Key[name, registry: registry].instance_eval(&block))
            else
              left
            end

          add_rule(__send__(type, rule))
        end

        def value(*predicates, &block)
          if predicates.empty? && !block
            ::Kernel.raise ::ArgumentError, "wrong number of arguments (given 0, expected at least 1)"
          end

          from_predicates = infer_predicates(predicates, :value).reduce(:and)
          from_block = block ? Key[name, registry: registry].instance_eval(&block) : nil

          rule = [from_predicates, from_block].compact.reduce(:and)

          add_rule(__send__(type, rule))
        end

        def maybe(*predicates, &block)
          left = key(:none?).not

          from_predicates = infer_predicates(predicates, :maybe).reduce(:and)
          from_block = block ? Key[name, registry: registry].instance_eval(&block) : nil

          right = [from_predicates, from_block].compact.reduce(:and) || key(:filled?)

          rule = left.then(right)

          add_rule(__send__(type, rule))
        end

        def each(*predicates, &block)
          rule = target.each(*predicates, &block)
          add_rule(__send__(type, new([target.type, [name, rule.to_ast]])))
        end

        def add_rule(rule)
          target.add_rule(rule)
        end

        def rules
          target.rules
        end

        def checks
          target.checks
        end

        def rule_ast
          rules.size > 0 ? target.rule_ast : [to_ast]
        end

        def to_ast
          rule_node = name ? [:rule, [name, node]] : node

          if deps.empty?
            rule_node
          else
            [:guard, [deps, rule_node]]
          end
        end

        def class
          Schema::Rule
        end

        def not
          new([:not, node])
        end

        def and(other)
          new([:and, [to_ast, other.to_ast]])
        end
        alias_method :&, :and

        def or(other)
          new([:or, [to_ast, other.to_ast]])
        end
        alias_method :|, :or

        def xor(other)
          new([:xor, [to_ast, other.to_ast]])
        end
        alias_method :^, :xor

        def then(other)
          new([:implication, [to_ast, other.to_ast]])
        end
        alias_method :>, :then

        def infer_predicates(predicates, macro = nil)
          predicates.flat_map(&::Kernel.method(:Array)).map do |predicate|
            name, *args = ::Kernel.Array(predicate)

            if macro && INVALID_PREDICATES[macro].include?(name)
              ::Kernel.raise InvalidSchemaError, "you can't use #{name} predicate with #{macro} macro"
            else
              key(name, args)
            end
          end
        end

        def with(new_options)
          self.class.new(node, options.merge(new_options))
        end

        def to_rule
          self
        end

        private

        def method_missing(meth, *args, &block)
          if target.predicate?(meth)
            target.__send__(meth, *args, &block)
          else
            super
          end
        end

        def key(predicate, args = [])
          new(target.node(predicate, *args))
        end

        def new(node)
          self.class.new(node, options)
        end
      end
    end
  end
end
