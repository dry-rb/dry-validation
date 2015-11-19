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

        def each(&block)
          Rule::Each.new(name, yield(self))
        end

        def method_missing(meth, *args, &block)
          if predicates.key?(meth)
            Rule::Value.new(name, predicates[meth].curry(*args))
          else
            super
          end
        end

        def respond_to_missing?(meth, _include_private = false)
          predicates.key?(meth) || super
        end
      end
    end
  end
end
