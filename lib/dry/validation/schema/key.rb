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

        def each(*predicates, &block)
          create_rule([type, [name, value.each(*predicates, &block).to_ast]])
        end

        def schema(other = nil, &block)
          create_rule([type, [name, value.schema(other, &block).to_ast]])
        end

        def hash?(&block)
          predicate = predicate(:hash?)

          if block
            val = value.instance_eval(&block)

            rule = create_rule(predicate)
              .and(create_rule([type, [name, val.to_ast]]))

            add_rule(rule)
            rule
          else
            add_rule(create_rule(predicate))
          end
        end

        def value
          Value[name, registry: registry]
        end

        private

        def method_missing(meth, *args, &block)
          registry.ensure_valid_predicate(meth, args)
          predicate = predicate(meth, args)

          if block
            val = value.instance_eval(&block)
            add_rule(create_rule([:and, [predicate, val.to_ast]]))
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
