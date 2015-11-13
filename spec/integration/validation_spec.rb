require 'byebug'

module Dry
  module Validation
    def self.Result(input)
      case input
      when Result then input
      else Result.new(input)
      end
    end

    class Result
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def success?
        @value
      end

      def failure?
        ! success?
      end

      def &(other)
        if failure?
          self
        else
          other
        end
      end
    end

    class Predicate
      attr_reader :fn

      class Composite < Predicate
      end

      def initialize(&block)
        @fn = block
      end

      def call(*args)
        Validation.Result(fn.call(*args))
      end

      def &(other)
        Predicate::Composite.new { |*args| Validation.Result(fn.call(*args) && fn.call(*args)) }
      end

      def inversed
        self.class.new { |*args| Validation.Result(!fn.(*args)) }
      end

      def curry(*args)
        self.class.new(&fn.curry.(*args))
      end
    end

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

RSpec.describe Dry::Validation do
  before do
    module Test
      class Predicates
        extend Dry::Container::Mixin

        register(:value?) do
          Dry::Validation::Predicate.new do |name, input|
            input.key?(name)
          end
        end

        register(:empty?) do
          Dry::Validation::Predicate.new do |input|
            case input
            when String, Array, Hash then input.empty?
            when nil then true
            else
              false
            end
          end
        end

        register(:filled?, self[:empty?].inversed)

        register(:present?) do
          Dry::Validation::Predicate.new do |name, input|
            self[:value?].(name, input) & self[:filled?].(input[name])
          end
        end
      end

      class Validation < Dry::Validation::Schema
        configure do |config|
          config.predicates = Predicates
        end

        attribute :name, :present?
      end
    end
  end

  describe 'defining predicates' do
    it 'works' do
      expect(Test::Predicates[:present?].(:name, name: 'Jane')).to be_success

      expect(Test::Predicates[:present?].(:name, {})).to be_failure
      expect(Test::Predicates[:present?].(:name, name: nil)).to be_failure
      expect(Test::Predicates[:present?].(:name, name: {})).to be_failure
      expect(Test::Predicates[:present?].(:name, name: [])).to be_failure
      expect(Test::Predicates[:present?].(:name, name: [])).to be_failure
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new

      expect(validation.(name: 'Jane')).to be_empty
      expect(validation.(name: '')).to eql(name: [validation.rules[:name]])
    end
  end
end
