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
            key_name = keys[0]

            @block = proc do
              key.failure(:acceptance, key: key_name) unless values[key_name].equal?(true)
            end
          end
        end
      end

      Rule.include(Acceptance::RuleMethods)
    end
  end
end
