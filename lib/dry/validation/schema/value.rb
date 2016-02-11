module Dry
  module Validation
    class Schema
      class Value < BasicObject
        attr_reader :name, :rules

        def initialize(name = nil, rules = [])
          @name = name
          @rules = rules
        end

        def class
          Value
        end

        def named(name)
          self.class.new(name, rules)
        end

        def key(name, &block)
          key_rule = named(name).key?(name)

          if block
            result = yield(Key.new(name))
            add_rule(key_rule.and(create_rule(result.to_ast)))
          else
            key_rule
          end
        end

        def each(&block)
          result = yield(Value.new)
          create_rule([:each, result.to_ast])
        end

        def add_rule(rule)
          rules << rule
          self
        end

        def to_ast
          ast = rules.map(&:to_ast)
          ast.size > 1 ? [:set, ast] : ast[0]
        end

        private

        def create_rule(node)
          Schema::Rule.new(node, name: name, target: self)
        end

        def method_missing(meth, *args, &block)
          key_rule = create_rule([:val, [:predicate, [meth, args]]])

          if block
            result = yield(Value.new)
            new_rule = create_rule([:and, [key_rule.to_ast, result.to_ast]])

            add_rule(new_rule)
          else
            key_rule
          end
        end
      end
    end
  end
end
