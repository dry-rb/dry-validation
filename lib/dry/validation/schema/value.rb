module Dry
  module Validation
    class Schema
      class Value < BasicObject
        include Schema::Definition

        attr_reader :name, :rules, :groups, :checks

        def initialize(name)
          @name = name
          @rules = []
          @groups = []
          @checks = []
        end

        def each(&block)
          val_rule = yield(self)

          each_rule =
            if val_rule.is_a?(Schema::Rule)
              val_rule.to_ary
            else
              [:set, [name, rules.map(&:to_ary)]]
            end

          Schema::Rule.new(name, [:each, [name, each_rule]])
        end

        private

        def method_missing(meth, *args, &block)
          rule = Schema::Rule.new(name, [:val, [name, [:predicate, [meth, args]]]])

          if block
            val_rule = yield

            if val_rule.is_a?(Schema::Rule)
              rule & val_rule
            else
              Schema::Rule.new(name, [:and, [rule.to_ary, [:set, [name, rules.map(&:to_ary)]]]])
            end
          else
            rule
          end
        end

        def respond_to_missing?(meth, _include_private = false)
          true
        end
      end
    end
  end
end
