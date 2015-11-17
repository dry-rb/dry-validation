require 'dry/validation/predicates'
require 'dry/validation/rule'
require 'dry/validation/error'
require 'dry/validation/dsl/key'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable

      setting :predicates, Predicates
      setting :rules, []

      attr_reader :rules

      def self.key(name)
        DSL::Key.new(name, config.predicates, config.rules)
      end

      def self.key?(name, &block)
        key(name).key?(&block)
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
