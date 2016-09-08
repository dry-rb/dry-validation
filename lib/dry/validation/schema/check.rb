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

          hash?.and(create_rule([:check, [[path], schema.to_ast]]))
        end

        private

        def method_missing(meth, *meth_args)
          vals, args = meth_args.partition { |arg| arg.class < DSL }

          keys = [path, vals.map(&:path)].reject(&:empty?)

          registry.ensure_valid_predicate(meth, args.size + keys.size, schema_class)
          predicate = predicate(meth, args)

          rule = create_rule([:check, [keys.reverse, predicate]], name)

          add_rule(rule)
          rule
        end
      end
    end
  end
end
