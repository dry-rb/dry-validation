RSpec.describe Dry::Validation::Schema, 'dynamic predicate args' do
  context 'with base rules' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def data
            %w(a b c)
          end
        end

        required(:letter).filled(included_in?: data)
      end
    end

    it 'evaluates predicate arguments' do
      expect(schema.(letter: 'a')).to be_success
      expect(schema.(letter: 'f')).to be_failure
    end
  end

  context 'with high-level rules' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def data
            %w(a b c)
          end
        end

        required(:letter).filled(:str?)

        rule(valid_letter: [:letter]) do |letter|
          letter.included_in?(data)
        end
      end
    end

    it 'evaluates predicate arguments' do
      expect(schema.(letter: 'a')).to be_success
      expect(schema.(letter: 'f')).to be_failure
    end
  end
end
