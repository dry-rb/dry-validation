require 'dry/validation/predicate'
require 'dry/validation/predicates'

module Dry
  module Validation
    module PredicateSet
      module Methods
        def predicate(name, &block)
          register(name) { Predicate.new(name, &block) }
        end
      end

      def self.extended(base)
        base.__send__(:extend, Dry::Container::Mixin)
        base.__send__(:extend, Methods)
      end
    end
  end
end
