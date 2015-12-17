RSpec.describe 'Schema with each and set rules' do
  subject(:validation) { schema.new }

  let(:schema) do
    Class.new(Dry::Validation::Schema) do
      key(:payments) do |payments|
        payments.array? do
          payments.each do |payment|
            payment.key(:method, &:str?)
            payment.key(:amount, &:float?)
          end
        end
      end
    end
  end

  describe '#messages' do
    it 'validates each payment against its set of rules' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 'wire', amount: 4.56 }
        ]
      }

      expect(validation.(input).messages).to eql({})
    end

    it 'validates presence of the method key for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { amount: 4.56 }
        ]
      }

      expect(validation.(input).messages[:payments]).to eql([
        [payments: [[method: [["method is missing"], nil]], input[:payments][1]]],
        input[:payments]
      ])
    end

    it 'validates type of the method value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 12, amount: 4.56 }
        ]
      }

      expect(validation.(input).messages[:payments]).to eql([
        [payments: [[method: [["method must be a string"], 12]], input[:payments][1]]],
        input[:payments]
      ])
    end

    it 'validates type of the amount value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 'wire', amount: '4.56' }
        ]
      }

      expect(validation.(input).messages[:payments]).to eql([
        [payments: [[amount: [["amount must be a float"], '4.56']], input[:payments][1]]],
        input[:payments]
      ])
    end
  end
end
