require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Value < DSL
        attr_reader :type

        class Check < Value
          private

          def method_missing(meth, *meth_args)
            vals, args = meth_args.partition { |arg| arg.class < DSL }

            keys = [name, *vals.map(&:name)]
            predicate = [:predicate, [meth, args]]

            rule = create_rule([:check, [name, predicate, keys]])
            add_rule(rule)
            rule
          end
        end

        def initialize(options = {})
          super
          @type = options[:type]
        end

        def class
          Value
        end

        def each(&block)
          val = Value[name].instance_eval(&block)
          create_rule([:each, val.to_ast])
        end

        def when(*predicates, &block)
          left = create_rule([])
            .infer_predicates(::Kernel.Array(predicates))
            .reduce(:and)

          right = Value.new(type: type)
          right.instance_eval(&block)

          add_rule(left.then(create_rule(right.to_ast)))
        end

        def value(name)
          Check[name, type: type, rules: rules]
        end

        def to_ast
          ast = rules.map(&:to_ast)
          ast.size > 1 ? [:set, ast] : ast[0]
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
