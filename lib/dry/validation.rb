# frozen_string_literal: true

require 'dry/validation/contract'
require 'dry/validation/macros'

module Dry
  # Main library namespace
  #
  # @api private
  module Validation
    extend Dry::Core::Extensions

    register_extension(:monads) do
      require 'dry/validation/extensions/monads'
    end

    register_extension(:hints) do
      require 'dry/validation/extensions/hints'
    end
  end
end
