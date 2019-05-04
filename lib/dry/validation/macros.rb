# frozen_string_literal: true

module Dry
  module Validation
    module Macros
      # @api public
      module Acceptance
        # @api public
        module RuleMethods
          # @api public
          def acceptance
            @block = proc do
              key.failure('must accept terms') unless values[keys[0]].equal?(true)
            end
          end
        end
      end

      Rule.include(Acceptance::RuleMethods)
    end
  end
end
