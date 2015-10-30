require 'dry/validation/support/deep_merge'

module Dry
  module Validation
    class RuleSet < ::Hash
      def <<(other)
        Support.deep_merge!(self, other)
      end
    end
  end
end
