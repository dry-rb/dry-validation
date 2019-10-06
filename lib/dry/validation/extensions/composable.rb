# frozen_string_literal: true

require 'dry/validation/contract'
require 'dry/validation/composition'
require 'dry/validation/composition/builder'
require 'dry/validation/composition/result'

module Dry
  module Validation
    # Extension to allow contracts to be composed of other contracts
    #
    # Current limitations
    #   - no support for sharing context between contracts
    #   - no way of specifying a contract for each element of array input
    #   - no way of conditionally applying a contract to the input
    #
    # @example
    #   Dry::Validation.load_extensions(:composable)
    #
    #   class PlayerContract < Dry::Validation::Contract
    #     schema do
    #       required(:name).filled(:string)
    #       required(:age).filled(:integer)
    #     end
    #
    #     rule(:age).validate(gteq?: 18)
    #   end
    #
    #   class CaptainContract < Dry::Validation::Contract
    #     schema do
    #       required(:became_captain_on).filled(:date)
    #     end
    #
    #     contract PlayerContract
    #   end
    #
    # @api public
    module Composable
      module ContractExtensions
        def self.prepended(contract)
          contract.class_eval do
            extend ClassInterface

            # we allow contracts with no schemas if they have a composition
            #
            # @!attribute [r] schema
            #   @return [Dry::Schema::Params, Dry::Schema::JSON, Dry::Schema::Processor]
            #   @api private
            option :schema, default: -> { self.class.__schema__ }

            # @!attribute [r] composition
            #   @return [Composition]
            #   @api private
            option :composition, default: -> { default_composition }

            # add composition to equalizer
            include Dry::Equalizer(:schema, :rules, :messages, :composition, inspect: false)
          end
        end

        # Apply the contract to an input including any composition
        #
        # @param [Hash] input The input to validate
        #
        # @return [Result,Composition::Result]
        #
        # @api public
        def call(input)
          return contract_result(input) if composition.empty?

          Composition::Result.new do |result|
            composition.call(input, result)
            result.add_result contract_result(input) if schema
          end
        end

        # Return a nice string representation
        #
        # @return [String]
        #
        # @api public
        def inspect
          parts = []
          parts << "schema=#{schema.inspect}" << "rules=#{rules.inspect}" if schema
          parts << "composition=#{composition.inspect}" unless composition.empty?

          "#<#{self.class} #{parts.join(' ')}>"
        end

        private

        def default_composition
          self.class.composition
        ensure
          raise SchemaMissingError, self.class if self.class.composition.empty? && !schema
        end

        module ClassInterface
          # declare that the passed contract should be applied to the input,
          # optionally at the specified path
          #
          # @example
          #   contract CustomerContract
          #
          # @example using a path
          #   contract AddressContract, path: :address
          #
          # @api public
          def contract(contract, path: nil)
            composition_builder.contract(contract, path: path)
          end

          # scope enclosed contracts to the specified path
          #
          # @example
          #   path :address do
          #     contract AddressContract
          #
          #     path :location do
          #       contract GeoLocation
          #     end
          #   end
          #
          # @api public
          def path(path, &block)
            composition_builder.path(path, &block)
          end

          # @return [Composition]
          #
          # @api private
          def composition
            @composition ||= begin
              steps = superclass.respond_to?(:composition) ? superclass.composition.steps : []
              Composition.new(steps)
            end
          end

          # @return [Composition::Builder]
          #
          # @api private
          def composition_builder
            @composition_builder ||= Composition::Builder.new(composition)
          end
        end
      end

      Contract.prepend(ContractExtensions)
    end
  end
end
