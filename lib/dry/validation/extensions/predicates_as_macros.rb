# frozen_string_literal: true

module Dry
  module Validation
    # Encapsulation of a dry-logic predicate.
    class Predicate
      # List of predicates to be imported.
      #
      # @see Dry::Validation::Contract
      WHITELIST = %i[gteq?].freeze

      # @api private
      REGISTRY = Dry::Schema::PredicateRegistry.new(
        Dry::Logic::Predicates
      ).freeze

      # @api private
      attr_reader :name

      # @api private
      def initialize(name)
        @name = name
      end

      # @api private
      def arg_names
        REGISTRY.arg_list(name).map(&:first)
      end

      # @api private
      def call(args)
        REGISTRY[name].(*args)
      end

      # @api private
      def add_failure_from_call(key, arg_values)
        message_opts = arg_names.zip(arg_values).to_h

        key.failure(name, message_opts)
      end
    end

    # Extension to use dry-logic predicates as macros.
    #
    # @see Dry::Validation::Predicate::WHITELIST Available predicates
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
    #       required(:name).filled(:integer)
    #     end
    #
    #     rule(:age).validate(gteq?: 18)
    #   end
    #
    #   AgeContract.new.(age: 17).errors.first.text
    #   # => 'must be greater than or equal to 18'
    class Contract
      # Make macros available for self and its descendants.
      def self.import_predicates_as_macros
        Predicate::WHITELIST.each do |name|
          predicate = Predicate.new(name)
          register_macro(name) do |macro:|
            predicate_args = [*macro.args, value]
            predicate.(predicate_args) ||
              predicate.add_failure_from_call(key, predicate_args)
          end
        end
      end
    end
  end
end
