require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Value < DSL
        attr_reader :type

        def initialize(options = {})
          super
          @type = options.fetch(:type, :key)
        end

        def class
          Value
        end

        def each(&block)
          val = Value[name].instance_eval(&block)
          create_rule([:each, val.to_ast])
        end

        def when(*predicates, &block)
          left = predicates.reduce(Check[path, type: type]) { |a, e| a.__send__(*::Kernel.Array(e)) }

          right = Value.new(type: type)
          right.instance_eval(&block)

          parent.add_check(left.then(create_rule(right.to_ast)))

          self
        end

        def confirmation
          add_check(check(:"#{name}_confirmation").eql?(check(name)))
        end

        def value(name)
          check(name, rules: rules)
        end

        def check(name, options = {})
          Check[name, options.merge(type: type)]
        end

        private

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
