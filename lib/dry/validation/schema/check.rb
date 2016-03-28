module Dry
  module Validation
    class Schema
      class Check < Value
        def class
          Check
        end

        def schema(other = nil, &block)
          schema = Schema.create_class(self, other, &block)

          if other
            schema.config.input_processor = other.class.config.input_processor
          end

          hash?.and(create_rule([:check, [name, schema.to_ast], [path]]))
        end

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
    end
  end
end
