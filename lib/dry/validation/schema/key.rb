require 'dry/validation/schema/attr'
require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class Key < BasicObject
        attr_reader :name, :rules

        def initialize(name, rules = [])
          @name = name
          @rules = rules
        end

        def class
          Key
        end

        def named(name)
          Value.new(name, rules)
        end

        def to_ast
          ast = rules.map(&:to_ast)
          [:key, [name, ast.size > 1 ? [:set, ast] : ast[0]]]
        end

        def key(name, &block)
          if block
            val = Value.new(name).key?(name)
            key = Key.new(name).instance_eval(&block)

            if key.class == Value
              add_rule(val.and(create_rule([:key, [name, key.to_ast]])))
            else
              add_rule(val.and(create_rule(key.to_ast)))
            end
          else
            named(name).key?(name)
          end
        end

        def add_rule(rule)
          rules << rule
          self
        end

        def not
          negated = create_rule([:not, to_ast])
          @rules = [negated]
          self
        end

        private

        def create_rule(node)
          Schema::Rule.new(node, target: self, name: name)
        end

        def method_missing(meth, *args, &block)
          predicate = [:predicate, [meth, args]]

          if block
            val = Value.new(name).instance_eval(&block)

            add_rule(
              create_rule([:and, [[:val, predicate], val.to_ast]])
            )
          else
            rule = create_rule([:key, [name, predicate]])
            add_rule(rule)
            rule
          end
        end
      end
    end
  end
end
