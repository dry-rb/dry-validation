require 'dry/validation/schema/definition'
require 'dry/validation/predicates'
require 'dry/validation/error'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable
      extend Definition

      setting :predicates, Predicates
      setting :rules, []

      attr_reader :rules

      def self.predicates
        config.predicates
      end

      def self.rules
        config.rules
      end

      def initialize
        @rules = self.class.config.rules
      end

      def call(input)
        rules.each_with_object(Error::Set.new) do |rule, errors|
          result = rule.(input)
          errors << Error.new(result, rule) if result.failure?
        end
      end
    end
  end
end
