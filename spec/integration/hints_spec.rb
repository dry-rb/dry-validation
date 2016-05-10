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
        required(:age) do |age|
          age.none? | (age.int? & age.gt?(18))
        end
      end
    end

    include_context '#messages'
  end

  context 'with i18n messages' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure { configure { |c| c.messages = :i18n } }

        required(:age) do |age|
          age.none? | (age.int? & age.gt?(18))
        end
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
end
