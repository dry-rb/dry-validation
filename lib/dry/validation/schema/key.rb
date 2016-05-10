require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Key < DSL
        attr_reader :parent

        def self.type
          :key
        end

        def class
          Key
        end

        def type
          self.class.type
        end

        def to_ast
          [type, [name, super]]
        end

        def hash?(&block)
          val = Value[name]
          val.instance_eval(&block)

          rule = create_rule([:val, [:predicate, [:hash?, []]]])
            .and(create_rule([type, [name, val.to_ast]]))

          add_rule(rule)

          rule
        end

        private

        def method_missing(meth, *args, &block)
          predicate = [:predicate, [meth, args]]

          if block
            val = Value[name].instance_eval(&block)
            add_rule(create_rule([:and, [[:val, predicate], val.to_ast]]))
          else
            rule = create_rule([type, [name, predicate]])
            add_rule(rule)
            rule
          end
        end
      end
    end
  end
end
