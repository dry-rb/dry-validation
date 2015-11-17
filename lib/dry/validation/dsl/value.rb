require 'dry/validation/rule'

module Dry
  module Validation
    module DSL
      class Value
        attr_reader :name, :predicates, :rules

        def initialize(name, predicates)
          @name = name
          @predicates = predicates
        end

        def key(name, &block)
          DSL::Key.new(name, predicates).key?(&block)
        end

        def to_ary
          rules
        end
        alias_method :to_a, :to_ary

        def method_missing(meth, *args, &block)
          if predicates.key?(meth)
            predicate = predicates[meth]
            Rule::Value.new(name, predicate.curry(*args))
          else
            super
          end
        end
      end

    end
  end
end
