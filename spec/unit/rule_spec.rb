# frozen_string_literal: true

require 'dry/validation/rule'

RSpec.describe Dry::Validation::Rule do
  subject(:rule) do
    Dry::Validation::Rule.new(keys: [], block: proc {})
  end

  describe '#parse_macros' do
    it 'works with single arg' do
      expect(rule.parse_macros(:foo))
        .to eql([[:foo]])
    end

    it 'works with multiple args' do
      expect(rule.parse_macros(:foo, :bar))
        .to eql([[:foo], [:bar]])
    end

    it 'works with a hash' do
      expect(rule.parse_macros(foo: :bar))
        .to eql([[:foo, [:bar]]])
    end

    it 'works with hash having multiple args' do
      expect(rule.parse_macros(foo: %i[bar baz]))
        .to eql([[:foo, %i[bar baz]]])
    end

    it 'works with multiple hashes' do
      expect(rule.parse_macros(foo: [:bar], baz: [:qux]))
        .to eql([[:foo, [:bar]], [:baz, [:qux]]])
    end
  end
end
