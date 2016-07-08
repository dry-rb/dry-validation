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

  context 'when duplicated key names are used in 2 subsequent levels as schemas' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:meta).schema do
          required(:meta).schema do
            required(:data).filled
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(meta: { meta: { data: 'this is fine' } })).to be_success
    end

    it 'fails when root key is missing' do
      expect(schema.({}).messages).to eql(meta: ['is missing'])
    end

    it 'fails when 1-level key is missing' do
      expect(schema.(meta: {}).messages).to eql(meta: { meta: ['is missing'] })
    end

    it 'fails when 1-level key value is invalid' do
      expect(schema.(meta: { meta: '' }).messages).to eql(
        meta: { meta: ['must be a hash'] }
      )
    end

    it 'fails when 2-level key is missing' do
      expect(schema.(meta: { meta: {} }).messages).to eql(
        meta: { meta: { data: ['is missing'] } }
      )
    end

    it 'fails when 2-level key value is invalid' do
      expect(schema.(meta: { meta: { data: '' } }).messages).to eql(
        meta: { meta: { data: ['must be filled'] } }
      )
    end
  end

  context 'with `each` + schema inside another schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:meta).schema do
          required(:data).each do
            schema do
              required(:info).schema do
                required(:name).filled
              end
            end
          end
        end
      end
    end

    it 'passes when data is valid' do
      expect(schema.(meta: { data: [{ info: { name: 'oh hai' } }] })).to be_success
    end

    it 'fails when root key is missing' do
      expect(schema.({}).messages).to eql(meta: ['is missing'])
    end

    it 'fails when root key value is invalid' do
      expect(schema.(meta: '').messages).to eql(meta: ['must be a hash'])
    end

    it 'fails when 1-level key is missing' do
      expect(schema.(meta: {}).messages).to eql(meta: { data: ['is missing'] })
    end

    it 'fails when 1-level key has invalid value' do
      expect(schema.(meta: { data: '' }).messages).to eql(meta: { data: ['must be an array'] })
    end

    it 'fails when 1-level key has value with a missing key' do
      expect(schema.(meta: { data: [{}] }).messages).to eql(
        meta: { data: { 0 => { info: ['is missing'] } } }
      )
    end

    it 'fails when 1-level key has value with an incorrect type' do
      expect(schema.(meta: { data: [{ info: ''}] }).messages).to eql(
        meta: { data: { 0 => { info: ['must be a hash'] } } }
      )
    end

    it 'fails when 1-level key has value with a key with an invalid value' do
      expect(schema.(meta: { data: [{ info: { name: '' } }] }).messages).to eql(
        meta: { data: { 0 => { info: { name: ['must be filled'] } } } }
      )
    end
  end

  context 'with 2-level `each` + schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:data).each do
          schema do
            required(:tags).each do
              required(:name).filled
            end
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(data: [{ tags: [{ name: 'red' }, { name: 'blue' }] }])).to be_success
    end

    it 'fails when 1-level element is not valid' do
      expect(schema.(data: [{}]).messages).to eql(
        data: { 0 => { tags: ['is missing'] } }
      )
    end

    it 'fails when 2-level element is not valid' do
      expect(schema.(data: [{ tags: [{ name: 'red' }, { name: '' }] }]).messages).to eql(
        data: { 0 => { tags: { 1 => { name: ['must be filled'] } } } }
      )
    end
  end
end
