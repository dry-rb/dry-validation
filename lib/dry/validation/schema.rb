require 'dry/validation/predicates'
require 'dry/validation/rule'
require 'dry/validation/error'

module Dry
  module Validation
    class ValueDSL
      attr_reader :name, :predicates, :rules

      def initialize(name, predicates)
        @name = name
        @predicates = predicates
      end

      def key(name, &block)
        KeyDSL.new(name, predicates)
      end

      def to_ary
        rules
      end
      alias_method :to_a, :to_ary

      def method_missing(meth, *args, &block)
        if predicates.key?(meth)
          predicate = predicates[meth]
          Rule::Value.new(name, predicate.curry(*args))
        else
          super
        end
      end
    end

    class KeyDSL
      attr_reader :name, :predicates, :rules

      def initialize(name, predicates, rules = nil, &block)
        @name = name
        @predicates = predicates
        @rules = rules
      end

      def method_missing(meth, *args, &block)
        if predicates.key?(meth)
          predicate = predicates[meth]
          key_rule = Rule::Key.new(name, predicate)

          rule =
            if block
              val_rule = yield(ValueDSL.new(name, predicates))
              key_rule.and(val_rule)
            else
              key_rule
            end

          rules << rule if rules
          rule
        else
          super
        end
      end
    end

    class Schema
      extend Dry::Configurable

      setting :predicates, Predicates
      setting :rules, []

      attr_reader :rules

      def self.key(name)
        KeyDSL.new(name, config.predicates, config.rules)
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
