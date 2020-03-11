# frozen_string_literal: true

require "dry/schema/predicate_registry"
require "dry/validation/contract"

module Dry
  module Validation
    # Predicate registry with additional needed methods.
    class PredicateRegistry < Schema::PredicateRegistry
      # List of predicates to be imported by `:predicates_as_macros`
      # extension.
      #
      # @see Dry::Validation::Contract
      WHITELIST = %i[
        filled? format? gt? gteq? included_in? includes? inclusion? is? lt?
        lteq? max_size? min_size? not_eql? odd? respond_to? size? true?
        uuid_v4?
      ].freeze

      # @api private
      def arg_names(name)
        arg_list(name).map(&:first)
      end

      # @api private
      def call(name, args)
        self[name].(*args)
      end

      # @api private
      def message_opts(name, arg_values)
        arg_names(name).zip(arg_values).to_h
      end
    end

    # Extension to use dry-logic predicates as macros.
    #
    # @see Dry::Validation::PredicateRegistry::WHITELIST Available predicates
    #
    # @example
    #   Dry::Validation.load_extensions(:predicates_as_macros)
    #
    #   class ApplicationContract < Dry::Validation::Contract
    #     import_predicates_as_macros
    #   end
    #
    #   class AgeContract < ApplicationContract
    #     schema do
    #       required(:age).filled(:integer)
    #     end
    #
    #     rule(:age).validate(gteq?: 18)
    #   end
    #
    #   AgeContract.new.(age: 17).errors.first.text
    #   # => 'must be greater than or equal to 18'
    #
    # @api public
    class Contract
      # Make macros available for self and its descendants.
      def self.import_predicates_as_macros
        registry = PredicateRegistry.new

        PredicateRegistry::WHITELIST.each do |name|
          register_macro(name) do |macro:|
            predicate_args = [*macro.args, value]
            message_opts = registry.message_opts(name, predicate_args)

            key.failure(name, message_opts) unless registry.(name, predicate_args)
          end
        end
      end
    end
  end
end
