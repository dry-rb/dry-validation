module Dry
  module Validation
    class Rule
      class Key < Rule
        def self.new(name, predicate)
          super(name, predicate.curry(name))
        end

        def type
          :key
        end

        def call(input)
          Validation.Result(input[name], predicate.(input), self)
        end
      end
    end
  end
end
