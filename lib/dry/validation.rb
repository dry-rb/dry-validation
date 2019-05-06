# frozen_string_literal: true

require 'dry/validation/contract'
require 'dry/validation/macros'

module Dry
  # Main library namespace
  #
  # @api public
  module Validation
    extend Dry::Core::Extensions

    register_extension(:monads) do
      require 'dry/validation/extensions/monads'
    end

    register_extension(:hints) do
      require 'dry/validation/extensions/hints'
    end

    # Register a new global macro
    #
    # @example
    #   Dry::Validation.register_macro(:even_numbers) do
    #     key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
    #   end
    #
    # @param [Symbol] name The name of the macro
    #
    # @return [self]
    #
    # @api public
    def self.register_macro(name, &block)
      Macros.register(name, &block)
      self
    end
  end
end
