require 'dry/validation/rule'

module Dry
  module Validation
    class Schema
      class Key
        attr_reader :name, :predicates, :rules

        def initialize(name, predicates, rules, &block)
          @name = name
          @predicates = predicates
          @rules = rules
        end

        def method_missing(meth, *args, &block)
          if predicates.key?(meth)
            key_rule = Rule::Key.new(name, predicates[meth])

            if block
              val_rule = yield(Value.new(name, predicates))

              rules << if val_rule.is_a?(Array)
                key_rule.and(Rule::Set.new(val_rule))
              else
                key_rule.and(val_rule)
              end
            else
              key_rule
            end
          else
            super
          end
        end
      end
    end
  end
end
