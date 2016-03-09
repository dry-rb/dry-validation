RSpec.describe 'Schema with each and set rules' do
  subject(:schema) do
    Dry::Validation.Schema do
      key(:payments).each do
        key(:method).required(:str?)
        key(:amount).required(:float?)
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

      expect(schema.(input).messages).to eql({})
    end

    it 'validates presence of the method key for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { amount: 4.56 }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { method: ['method is missing'] } }
      )
    end

    it 'validates type of the method value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 12, amount: 4.56 }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { method: ['method must be a string'] } }
      )
    end

    it 'validates type of the amount value for each payment' do
      input = {
        payments: [
          { method: 'cc', amount: 1.23 },
          { method: 'wire', amount: '4.56' }
        ]
      }

      expect(schema.(input).messages).to eql(
        payments: { 1 => { amount: ['amount must be a float'] } }
      )
    end
  end
end
