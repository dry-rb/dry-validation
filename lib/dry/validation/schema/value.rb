module Dry
  module Validation
    class Schema
      class Value < BasicObject
        include Schema::Definition

        attr_reader :name, :rules, :groups

        def initialize(name)
          @name = name
          @rules = []
          @groups = []
        end

        def each(&block)
          rule = yield(self).to_ary
          Schema::Rule.new([:each, [name, rule]])
        end

        private

        def method_missing(meth, *args, &block)
          rule = Schema::Rule.new([:val, [name, [:predicate, [meth, args]]]])

          if block
            val_rule = yield

            if val_rule.is_a?(Schema::Rule)
              rule & val_rule
            else
              Schema::Rule.new([:and, [rule.to_ary, [:set, [name, rules.map(&:to_ary)]]]])
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
