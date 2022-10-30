# frozen_string_literal: true

require "dry/monads"
require "dry/monads/version"

if Gem::Version.new(Dry::Monads::VERSION) < Gem::Version.new("1.6.0")
  raise "dry-validation requires dry-monads >= 1.6.0"
end

module Dry
  module Validation
    # Monad extension for contract results
    #
    # @example
    #   Dry::Validation.load_extensions(:monads)
    #
    #   contract = Dry::Validation::Contract.build do
    #     schema do
    #       required(:name).filled(:string)
    #     end
    #   end
    #
    #   contract.call(name: nil).to_monad
    #
    # @api public
    class Result
      include Dry::Monads::Result::Mixin

      # Returns a result monad
      #
      # @return [Dry::Monads::Result]
      #
      # @api public
      def to_monad
        success? ? Success(self) : Failure(self)
      end
    end
  end
end
