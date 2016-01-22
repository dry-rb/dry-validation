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

        def optional(&block)
          key_rule = key?

          val_rule = yield(Value.new(name, target))

          target.rules <<
            if val_rule.is_a?(::Array)
              create_rule([:implication, [key_rule.to_ary, [:set, [name, val_rule.map(&:to_ary)]]]])
            else
              create_rule([:implication, [key_rule.to_ary, val_rule.to_ary]])
            end
        end

        private

        def create_rule(node)
          Schema::Rule.new(name, node, target)
        end

        def method_missing(meth, *args, &block)
          key_node = [identifier, [name, [:predicate, [meth, args]]]]

          if block
            val_rule = yield(Value.new(name, target))

            target.rules <<
              if val_rule.is_a?(::Array)
                create_rule([:and, [key_node, [:set, [name, val_rule.map(&:to_ary)]]]])
              else
                create_rule([:and, [key_node, val_rule.to_ary]])
              end
          else
            create_rule(key_node)
          end
        end

        def respond_to_missing?(*)
          true
        end
      end
    end
  end
end
