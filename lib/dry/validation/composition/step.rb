# frozen_string_literal: true

module Dry
  module Validation
    class Composition
      # A composition step consists of a contract optionally at a prefix
      #
      # @api private
      class Step
        include Dry::Equalizer(:contract, :prefix, inspect: false)

        # @return [Contract]
        #
        # @api private
        attr_reader :contract

        # @return [Schema::Path]
        #
        # @api private
        attr_reader :prefix

        def initialize(contract, prefix = nil)
          @contract = contract
          @prefix = prefix
        end

        # call contract (at prefix) on the input and add it to the result
        #
        # @param [Composition::Result]
        # @param [Hash]
        #
        # @return [Composition::Result]
        #
        # @api private
        def call(input, result = Composition::Result)
          input = input.dig(*prefix) if prefix
          contract_instance = contract.respond_to?(:call) ? contract : contract.new
          result.add_result(contract_instance.call(input), prefix)
        end
      end
    end
  end
end
