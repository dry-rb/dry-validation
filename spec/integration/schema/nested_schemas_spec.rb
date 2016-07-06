RSpec.describe Schema, 'nested schemas' do
  context 'with a 2-level deep schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:meta).schema do
          required(:info).schema do
            required(:details).filled
            required(:meta).filled
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(meta: { info: { details: 'Krakow', meta: 'foo' }})).to be_success
    end

    it 'fails when root key is missing' do
      expect(schema.({}).messages).to eql(meta: ['is missing'])
    end

    it 'fails when 1-level key is missing' do
      expect(schema.(meta: {}).messages).to eql(
        meta: { info: ['is missing'] }
      )
    end

    it 'fails when 2-level key is missing' do
      expect(schema.(meta: { info: {} }).messages).to eql(
        meta: { info: { details: ['is missing'], meta: ['is missing'] } }
      )
    end

    it 'fails when 1-level key has invalid value' do
      expect(schema.(meta: { info: nil, meta: 'foo' }).messages).to eql(
        meta: { info: ['must be a hash'] }
      )
    end

    it 'fails when 2-level key has invalid value' do
      expect(schema.(meta: { info: { details: nil, meta: 'foo' } }).messages).to eql(
        meta: { info: { details: ['must be filled'] } }
      )
    end
  end

  context 'when duplicated key names are used in 2 subsequent levels' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:meta).schema do
          required(:meta).filled
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(meta: { meta: 'data' })).to be_success
    end

    it 'fails when root key is missing' do
      expect(schema.({}).messages).to eql(meta: ['is missing'])
    end

    it 'fails when 1-level key is missing' do
      expect(schema.(meta: {}).messages).to eql(meta: { meta: ['is missing'] })
    end

    it 'fails when 1-level key value is invalid' do
      expect(schema.(meta: { meta: '' }).messages).to eql(
        meta: { meta: ['must be filled'] }
      )
    end
  end
end
