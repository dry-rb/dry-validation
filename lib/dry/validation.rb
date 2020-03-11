# frozen_string_literal: true

require "dry/validation/constants"
require "dry/validation/contract"
require "dry/validation/macros"

# Main namespace
#
# @api public
module Dry
  # Main library namespace
  #
  # @api public
  module Validation
    extend Dry::Core::Extensions
    extend Macros::Registrar

    register_extension(:monads) do
      require "dry/validation/extensions/monads"
    end

    register_extension(:hints) do
      require "dry/validation/extensions/hints"
    end

    register_extension(:predicates_as_macros) do
      require "dry/validation/extensions/predicates_as_macros"
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
    #
    def self.Contract(options = EMPTY_HASH, &block)
      Contract.build(options, &block)
    end

    # This is needed by Macros::Registrar
    #
    # @api private
    def self.macros
      Macros
    end
  end
end
