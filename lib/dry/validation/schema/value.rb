module Dry
  module Validation
    class Schema
      class Value < BasicObject
        include Schema::Definition

        attr_reader :name, :target

        def initialize(name, target)
          @name = name
          @target = target
        end

        def each(&block)
          val_rule = yield(self)

          each_rule =
            if val_rule.is_a?(Schema::Rule)
              val_rule.to_ary
            else
              [:set, [name, rules.map(&:to_ary)]]
            end

          create_rule([:each, [name, each_rule]])
        end

        private

        def create_rule(node)
          Schema::Rule.new(name, node, target)
        end

        def method_missing(meth, *args, &block)
          new_rule = create_rule([:val, [name, [:predicate, [meth, args]]]])

          if block
            val_rule = yield

            if val_rule.is_a?(Schema::Rule)
              new_rule & val_rule
            else
              create_rule([:and, [new_rule.to_ary, [:set, [name, rules.map(&:to_ary)]]]])
            end
          else
            new_rule
          end
        end

        def respond_to_missing?(meth, _include_private = false)
          true
        end
      end
    end
  end
end
