# frozen_string_literal: true

require 'dry/validation/composition/step'

module Dry
  module Validation
    # A Composition is a list of steps
    #
    # @see Dry::Validation::Composable
    #
    # @api private
    class Composition
      include Dry::Equalizer(:steps, inspect: false)

      # @return [Array]
      #
      # @api private
      attr_reader :steps

      # @param [Array] initial steps array
      def initialize(steps = EMPTY_ARRAY)
        @steps = steps.dup
      end

      def inspect
        steps_str = steps.map do |s|
          s.prefix ? "#{s.prefix.to_a.join(DOT)} => #{s.contract}" : s.contract
        end.join(', ')

        "#<#{self.class.name} steps=[#{steps_str}]>"
      end

      # @return [Bool]
      #
      # @api private
      def empty?
        steps.empty?
      end

      # apply our steps to the input recording in result
      #
      # @param [Composition::Result]
      # @param [Hash]
      #
      # @return [Composition::Result]
      #
      # @api private
      def call(input, result = Composition::Result.new)
        steps.reduce(result) { |final_result, step| step.call(input, final_result) }
      end

      # add a new step to the composition
      #
      # @param [Contract]
      # @param [Schema::Path] optional
      #
      # @api private
      def add_step(contract, prefix)
        steps << Step.new(contract, prefix)
        self
      end
    end
  end
end
