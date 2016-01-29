require 'dry/validation/schema/key'
require 'dry/validation/schema/attr'
require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class Value < BasicObject
        class Set < Value
          def to_ast
            rules.size > 1 ? [:set, [id, super]] : super
          end
        end

        attr_reader :id, :rules, :checks

        def initialize(id = nil)
          @id = id
          @rules = []
          @checks = []
        end

        def class
          Value
        end

        def key(name, &block)
          define(Key, name, &block)
        end

        def optional(name, &block)
          Key.new(name, self).optional(&block)
        end

        def attr(name, &block)
          define(Attr, name, &block)
        end

        def value(name)
          Schema::Rule::Result.new(name, [], target: self)
        end

        def each(&block)
          result = yield(Value::Set.new(id))
          create_rule([:each, [id, result.to_ast]])
        end

        def rule(name, &block)
          if block
            predicate = yield

            checks << Schema::Rule.new(
              name,
              [:check, [name, predicate.to_ast, predicate.keys]],
              target: self, keys: predicate.keys
            )

            checks.last
          else
            self[name].to_success_check
          end
        end

        def add_rule(rule)
          rules << rule
          self
        end

        def add_check(rule)
          checks << rule
          self
        end

        def to_ast
          arr = rules.map(&:to_ast)
          rules.size > 1 ? arr : arr[0]
        end

        private

        def define(type, name, &block)
          key = type.new(name, self)
          key.__send__(key.predicate, &block)
        end

        def [](name)
          rules.detect { |rule| rule.name == name }
        end

        def create_rule(node)
          Schema::Rule.new(id, node, target: self)
        end

        def method_missing(meth, *args, &block)
          val_rule = create_rule([:val, [id, [:predicate, [meth, args]]]])

          new_rule =
            if block
              result = yield
              create_rule([:and, [val_rule.to_ast, result.to_ast]])
            else
              val_rule
            end

          add_rule(new_rule)

          new_rule
        end
      end
    end
  end
end
