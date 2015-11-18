require 'dry/validation/rule'

module Dry
  module Validation
    class Schema
      class Value
        include Schema::Definition

        attr_reader :name, :predicates, :rules

        def initialize(name, predicates)
          @name = name
          @predicates = predicates
          @rules = []
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
