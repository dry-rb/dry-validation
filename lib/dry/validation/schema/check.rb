module Dry
  module Validation
    class Schema
      class Check < Value
        def class
          Check
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
