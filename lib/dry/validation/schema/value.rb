module Dry
  module Validation
    class Schema
      class Value < BasicObject
        include Schema::Definition

        attr_reader :name

        def initialize(name)
          @name = name
        end

        def each(&block)
          result = yield(self)
          create_rule([:each, [name, result.to_ast]])
        end

        private

        def create_rule(node)
          Schema::Rule.new(name, node, target: target)
        end

        def method_missing(meth, *args, &block)
          val_rule = create_rule([:val, [name, [:predicate, [meth, args]]]])

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
