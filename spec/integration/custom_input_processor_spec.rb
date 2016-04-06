RSpec.describe Dry::Validation do
  Dry::Types.register('custom.boolean') do
    ->(value) do
      case value
      when 'yay' then true
      when 'nay' then false
      else value
      end
    end
  end

  class CustomInputProcessor < Dry::Validation::InputProcessorCompiler::Form
    PREDICATE_MAP = {
      bool?: 'custom.boolean',
    }
  end

  subject(:schema) do
    Dry::Validation.Form do
      configure do
        config.input_processor = CustomInputProcessor.new
      end

      key(:boolean).required(:bool?)
    end
  end

  describe 'custom input processors' do
    it 'allows custom input processors' do
      expect(schema.(boolean: 'yay').output).to eq(boolean: true)
      expect(schema.(boolean: 'nay').output).to eq(boolean: false)
    end
  end
end
