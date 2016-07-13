module Mutant
  class Selector
    class Expression < self
      def call(_subject)
        integration.all_tests
      end
    end
  end
end
