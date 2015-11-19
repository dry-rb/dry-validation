require 'dry/validation/schema/definition'
require 'dry/validation/predicates'
require 'dry/validation/error'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable
      extend Definition

      setting :predicates, Predicates

      def self.predicates
        config.predicates
      end

      def self.rules
        @__rules__ ||= []
      end

      attr_reader :rules

      def initialize
        @rules = self.class.rules
      end

      def call(input)
        rules.each_with_object(Error::Set.new) do |rule, errors|
          result = rule.(input)
          errors << Error.new(result) if result.failure?
        end
      end
    end
  end
end
