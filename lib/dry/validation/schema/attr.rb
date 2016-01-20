module Dry
  module Validation
    class Schema
      class Attr < BasicObject
        attr_reader :name, :rules

        def initialize(name, rules, &block)
          @name = name
          @rules = rules
        end

        private

        def method_missing(meth, *args, &block)
          attr_rule = [:attr, [name, [:predicate, [meth, args]]]]

          if block
            val_rule = yield(Value.new(name))

            rules <<
              if val_rule.is_a?(::Array)
                Schema::Rule.new(name, [:and, [attr_rule, [:set, [name, val_rule.map(&:to_ary)]]]])
              else
                Schema::Rule.new(name, [:and, [attr_rule, val_rule.to_ary]])
              end
          else
            Schema::Rule.new(name, attr_rule)
          end
        end

        def respond_to_missing?(*)
          true
        end
      end
    end
  end
end
