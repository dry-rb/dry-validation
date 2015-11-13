module Dry
  module Validation
    class Schema
      extend Dry::Configurable

      setting :predicates
      setting :rules, Hash.new { |k, v| k[v] = [] }

      attr_reader :rules

      def self.attribute(name, predicate)
        config.rules[name] = config.predicates[predicate].curry(name)
      end

      def initialize
        @rules = self.class.config.rules
      end

      def call(input)
        rules.each_with_object(Hash.new { |k,v| k[v] = [] }) do |(name, rule), errors|
          result = rule.(input)
          errors[name] << rule if result.failure?
        end
      end
    end
  end
end
