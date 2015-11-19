module Dry
  module Validation
    class Schema
      module Definition
        def key(name, &block)
          Key.new(name, predicates, rules).key?(&block)
        end
      end
    end
  end
end

require 'dry/validation/schema/value'
require 'dry/validation/schema/key'
