require 'dry/validation/schema/attr'
require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class Key < BasicObject
        attr_reader :name, :rules

        def initialize(name)
          @name = name
          @rules = []
        end

        def class
          Key
        end

        def to_ast
          ast = rules.map(&:to_ast)
          ast.size > 1 ? [:set, ast] : ast[0]
        end

        def key(name, &block)
          key_rule = Value.new(name).key?(name)

          if block
            result = yield(Key.new(name))
            add_rule(key_rule.and(create_rule(result.to_ast)))
          else
            key_rule
          end
        end

        def add_rule(rule)
          rules << rule
          self
        end

        private

        def create_rule(node)
          Schema::Rule.new(node, target: self, name: name)
        end

        def method_missing(meth, *args, &block)
          predicate = [:predicate, [meth, args]]

          if block
            result = yield(Value.new(name))
            create_rule([:key, [name, [:and, [[:val, predicate], result.to_ast]]]])
          else
            create_rule([:key, [name, predicate]])
          end
        end
      end
    end
  end
end
