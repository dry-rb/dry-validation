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
            key = Key.new(name).instance_eval(&block)
            add_rule(key_rule.and(create_rule(key.to_ast)))
          else
            key_rule
          end
        end

        def each(&block)
          result = Value.new(name).instance_eval(&block)
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
          val_rule = create_rule([:val, [:predicate, [meth, args]]])

          if block
            val = Value.new.instance_eval(&block)
            new_rule = create_rule([:and, [val_rule.to_ast, val.to_ast]])

            add_rule(new_rule)
          else
            val_rule
          end
        end
      end
    end
  end
end
