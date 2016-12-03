require 'dry/validation/messages/i18n'

RSpec.describe 'Validation hints' do
  shared_context '#messages' do
    it 'provides hints for additional rules that were not checked' do
      expect(schema.(age: '17').messages).to eql(
        age: ['must be an integer', 'must be greater than 18']
      )
    end

    it 'skips type-check rules' do
      expect(schema.(age: 17).messages).to eql(
        age: ['must be greater than 18']
      )
    end
  end

  context 'with yaml messages' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:age).maybe(:int?, gt?: 18)
      end
    end

    include_context '#messages'
  end

  context 'with i18n messages' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure { configure { |c| c.messages = :i18n } }

        required(:age).maybe(:int?, gt?: 18)
      end
    end

    include_context '#messages'
  end

  context 'when type expectation is specified' do
    subject(:schema)  do
      Dry::Validation.Schema do
        required(:email).filled
        required(:name).filled(:str?, size?: 5..25)
      end
    end

    it 'infers message for specific type' do
      expect(schema.(email: 'jane@doe', name: 'HN').messages).to eql(
        name: ['length must be within 5 - 25']
      )
    end
  end

  context 'when predicate failed and there is a corresponding hint generated' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:age).value(lt?: 23)
      end
    end

    it 'provides only failure error message' do
      result = schema.call(age: 23)
      expect(result.messages).to eql(age: ['must be less than 23'])
    end
  end

  context 'with a nested schema with same rule names' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:code).filled(:str?, eql?: 'foo')

        required(:nested).schema do
          required(:code).filled(:str?, eql?: 'bar')
        end
      end
    end

    it 'provides error messages' do
      result = schema.call(code: 'x', nested: { code: 'y' })

      expect(result.messages).to eql(
        code: ['must be equal to foo'],
        nested: {
          code: ['must be equal to bar']
        }
      )
    end

    it 'provides hints' do
      result = schema.call(code: '', nested: { code: '' })

      expect(result.messages).to eql(
        code: ['must be filled', 'must be equal to foo'],
        nested: {
          code: ['must be filled', 'must be equal to bar']
        }
      )
    end
  end

  context 'with an each rule' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:nums).each(:int?, gt?: 0)
      end
    end

    it 'provides hints for each element' do
      expect(schema.(nums: [1, 'foo', 0]).messages).to eql(
        nums: {
          1 => ['must be an integer', 'must be greater than 0'],
          2 => ['must be greater than 0']
        }
      )
    end
  end

  context 'with a format? predicate' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:name).value(size?: 2, format?: /xy/)
      end
    end

    it 'skips hints' do
      expect(schema.(name: 'x').messages[:name]).to_not include('is in invalid format')
      expect(schema.(name: 'ab').messages[:name]).to include('is in invalid format')
    end
  end

  context 'when the message uses input value' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def self.messages
            Messages.default.merge(
              en: {
                errors: {
                  blue?: {
                    failure: '%{value} is not equal to blue',
                    hint: 'must be equal to blue'
                  }
                }
              }
            )
          end

          def blue?(value)
            value == 'blue'
          end
        end

        required(:pill).filled(:blue?)
      end
    end

    it 'provides a correct failure message' do
      expect(schema.(pill: 'red').messages).to eql(
        pill: ['red is not equal to blue']
      )
    end

    it 'provides a correct hint' do
      expect(schema.(pill: nil).messages).to eql(
        pill: ['must be filled', 'must be equal to blue']
      )
    end
  end
end
