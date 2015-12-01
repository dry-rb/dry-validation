module Dry
  module Validation
    class Schema
      module Definition
        def key(name, &block)
          Key.new(name, rules).key?(&block)
        end

        def optional(name, &block)
          Key.new(name, rules).optional(&block)
        end

        def rule(name, **options)
          predicate, rules = options.to_a.first
          identifier = { name => rules }

          groups << [:group, [identifier, [:predicate, predicate]]]
        end
      end
    end
  end
end

require 'dry/validation/schema/rule'
require 'dry/validation/schema/value'
require 'dry/validation/schema/key'
