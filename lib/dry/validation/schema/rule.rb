module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node, :type, :target, :deps, :options

        def initialize(node, options = {})
          @node = node
          @type = options.fetch(:type, :and)
          @deps = options.fetch(:deps, [])
          @name = options.fetch(:name)
          @target = options.fetch(:target)
          @options = options
        end

        def schema(other = nil, &block)
          schema = Schema.create_class(target, other, &block)
          rule = __send__(type, key(:hash?).and(key(schema)))
          add_rule(rule)
        end

        def required(*predicates)
          rule = ([key(:filled?)] + infer_predicates(predicates)).reduce(:and)

          add_rule(__send__(type, rule))
        end

        def maybe(*predicates)
          rule =
            if predicates.size > 0
              key(:none?).or(infer_predicates(predicates).reduce(:and))
            else
              key(:none?).or(key(:filled?))
            end

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
          if deps.empty?
            node
          else
            [:guard, [deps, node]]
          end
        end

        def class
          Schema::Rule
        end

        def not
          new([:not, node])
        end

        def and(other)
          new([:and, [node, other.to_ast]])
        end
        alias_method :&, :and

        def or(other)
          new([:or, [node, other.to_ast]])
        end
        alias_method :|, :or

        def xor(other)
          new([:xor, [node, other.to_ast]])
        end
        alias_method :^, :xor

        def then(other)
          new([:implication, [node, other.to_ast]])
        end
        alias_method :>, :then

        def infer_predicates(predicates)
          predicates.map do |predicate|
            name, *args = ::Kernel.Array(predicate).first
            key(name, args)
          end
        end

        def with(new_options)
          self.class.new(node, options.merge(new_options))
        end

        private

        def key(predicate, args = [])
          node =
            if predicate.is_a?(::Symbol)
              [target.type, [name, [:predicate, [predicate, args]]]]
            elsif predicate.respond_to?(:rule)
              [target.type, [name, [:type, predicate]]]
            elsif predicate < ::Dry::Types::Struct
              [target.type, [name, [:schema, Schema.create_class(target, predicate)]]]
            else
              [target.type, [name, predicate.to_ast]]
            end

          new(node)
        end

        def new(node)
          self.class.new(node, options)
        end
      end
    end
  end
end
