module Dry
  module Validation
    class Schema
      class Key < BasicObject
        attr_reader :name, :target

        def initialize(name, target, &block)
          @name = name
          @target = target
        end

        def identifier
          :key
        end

        def predicate
          :"#{identifier}?"
        end

        def optional(&block)
          if block
            result = yield(Value::Set.new(name))
            target.add_rule(key?.then(result))
          else
            key?.to_implication
          end
        end

        def val_name
          if target.id != name
            [target.id, name].flatten
          else
            name
          end
        end

        private

        def create_rule(node)
          Schema::Rule.new(name, node, target: target)
        end

        def method_missing(meth, *args, &block)
          key_rule = create_rule([identifier, [name, [:predicate, [meth, args]]]])

          if block
            result = yield(Value::Set.new(val_name))
            new_rule = create_rule([:and, [key_rule.to_ast, result.to_ast]])

            target.checks.concat(result.checks)

            target.add_rule(new_rule)
          else
            key_rule
          end
        end
      end
    end
  end
end
