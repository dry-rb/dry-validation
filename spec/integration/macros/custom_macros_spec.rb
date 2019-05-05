# frozen_string_literal: true

RSpec.describe 'Defining custom macros' do
  subject(:contract) do
    Class.new(Test::BaseContract) do
      schema do
        required(:numbers).array(:integer)
      end

      rule(:numbers).validate(:even_numbers)
    end.new
  end

  before do
    class Test::BaseContract < Dry::Validation::Contract; end
  end

  shared_context 'a contract with a custom macro' do
    it 'succeeds with valid input' do
      expect(contract.(numbers: [2, 4, 6])).to be_success
    end

    it 'fails with invalid input' do
      expect(contract.(numbers: [1, 2, 3]).errors.to_h).to eql(numbers: ['all numbers must be even'])
    end
  end

  context 'using macro from the global registry' do
    include_context 'a contract with a custom macro' do
      before do
        Dry::Validation::Macros.register(:even_numbers) do
          key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        end
      end

      after do
        Dry::Validation::Macros.container._container.delete('even_numbers')
      end
    end
  end

  context 'using macro from contract itself' do
    include_context 'a contract with a custom macro' do
      before do
        Test::BaseContract.macros.register(:even_numbers) do
          key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        end
      end

      after do
        Test::BaseContract.macros._container.delete('even_numbers')
      end
    end
  end
end
