require 'dry/validation/rule'
require 'dry/validation/dsl/value'

module Dry
  module Validation
    module DSL
      class Key
        attr_reader :name, :predicates, :rules

        def initialize(name, predicates, rules = nil, &block)
          @name = name
          @predicates = predicates
          @rules = rules
        end

        def method_missing(meth, *args, &block)
          if predicates.key?(meth)
            predicate = predicates[meth]
            key_rule = Rule::Key.new(name, predicate)

            rule =
              if block
                val_rule = yield(DSL::Value.new(name, predicates))
                key_rule.and(val_rule)
              else
                key_rule
              end

            rules << rule if rules
            rule
          else
            super
          end
        end
      end
    end
  end
end
