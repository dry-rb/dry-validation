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
    end
  end
end

RSpec.describe Dry::Validation do
  describe 'defining predicates' do
    it 'works' do
      module Test
        class Rules
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
      end

      expect(Test::Rules[:present?].(:name, name: 'Jane')).to be_success

      expect(Test::Rules[:present?].(:name, {})).to be_failure
      expect(Test::Rules[:present?].(:name, name: nil)).to be_failure
      expect(Test::Rules[:present?].(:name, name: {})).to be_failure
      expect(Test::Rules[:present?].(:name, name: [])).to be_failure
      expect(Test::Rules[:present?].(:name, name: [])).to be_failure
    end
  end
end
