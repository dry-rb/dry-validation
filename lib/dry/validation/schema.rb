require 'dry/validation/predicates'
require 'dry/validation/rule'

module Dry
  module Validation
    class ValueDSL
      attr_reader :name, :predicates, :rules

      def initialize(name, predicates, &block)
        @name = name
        @predicates = predicates
        @rules = []
      end

      def to_ary
        rules
      end
      alias_method :to_a, :to_ary

      def method_missing(meth, *args, &block)
        predicate = predicates[meth]

        if predicate
          rules << Rule.new(name, predicate.curry(*args))
          self
        else
          super
        end
      end
    end

    class KeyDSL
      attr_reader :name, :predicates, :rules

      def initialize(name, predicates, rules, &block)
        @name = name
        @predicates = predicates
        @rules = rules
      end

      def method_missing(meth, *args, &block)
        predicate = predicates[meth]

        if predicate
          rule = Rule::Key.new(name, predicate)

          if block
            rules[name] = rule.compose(*yield(ValueDSL.new(name, predicates)))
          else
            rules[name] = rule
          end

          self
        else
          super
        end
      end
    end

    class Schema
      extend Dry::Configurable

      setting :predicates, Predicates
      setting :rules, Hash.new { |k, v| k[v] = [] }

      attr_reader :rules

      def self.key(name)
        KeyDSL.new(name, config.predicates, config.rules)
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
