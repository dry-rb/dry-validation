module Dry
  module Validation
    class Rule
      class Each < Rule
        def call(input)
          Validation.Result(input, input.map { |element| predicate.(element) }, self)
        end

        def type
          :each
        end
      end
    end
  end
end
