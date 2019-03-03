# frozen_string_literal: true

require 'dry/validation/contract'

module Dry
  # Main library namespace
  #
  # @api private
  module Validation
    extend Dry::Core::Extensions

    register_extension(:monads) do
      require 'dry/validation/extensions/monads'
    end
  end
end
