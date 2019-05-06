# frozen_string_literal: true

require 'dry/validation/constants'
require 'dry/validation/contract'
require 'dry/validation/macros'

# Main namespace
#
# @api public
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

    # Define a contract and build its instance
    #
    # @example
    #   my_contract = Dry::Validation.Contract do
    #     params do
    #       required(:name).filled(:string)
    #     end
    #   end
    #
    #   my_contract.call(name: "Jane")
    #
    # @param [Hash] options Contract options
    #
    # @see Contract
    #
    # @return [Contract]
    #
    # @api public
    def self.Contract(options = EMPTY_HASH, &block)
      Contract.build(options, &block)
    end
  end
end
