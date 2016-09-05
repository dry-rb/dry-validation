RSpec.describe 'Macros #input' do
  context 'with a flat schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        input :hash?

        required(:foo).filled
      end
    end

    it 'passes when input is valid' do
      expect(schema.(foo: "bar")).to be_successful
    end

    it 'prepends a rule for the input' do
      expect(schema.(nil).messages).to eql(["must be a hash"])
    end

    it 'applies other rules when input has expected type' do
      expect(schema.(foo: '').messages).to eql(foo: ["must be filled"])
    end
  end

  context 'with a nested schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        input(:hash?)

        required(:foo).schema do
          required(:bar).schema do
            required(:baz).filled
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(foo: { bar: { baz: "present" }})).to be_successful
    end

    it 'fails when input has invalid type' do
      expect(schema.(nil).messages).to eql(["must be a hash"])
    end

    it 'fails when 1-level key is missing' do
      expect(schema.(foo: {}).messages).to eql(foo: { bar: ["is missing"] })
    end

    it 'fails when 2-level key has invalid value' do
      expect(schema.(foo: { bar: { baz: '' }}).messages).to eql(
        foo: { bar: { baz: ['must be filled'] } }
      )
    end
  end

  context 'when 2 nested schemas are under the same key' do
    subject(:schema) do
      Dry::Validation.Schema do
        input :hash?

        required(:meta).schema do
          required(:meta).schema do
            required(:data).filled
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(meta: { meta: { data: 'sutin' } })).to be_success
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

    it 'fails when 2-level key value is invalid' do
      expect(schema.(meta: { meta: { data: '' } }).messages).to eql(
        meta: { meta: { data: ['must be filled'] } }
      )
    end
  end

  context 'using more than one predicate' do
    subject(:schema) do
      Dry::Validation.Schema do
        input :hash?, size?: 2

        required(:foo).filled
      end
    end

    it 'passes when input is valid' do
      expect(schema.(foo: "bar", bar: "baz")).to be_successful
    end

    it 'fails when one of the root-rules fails' do
      expect(schema.(foo: "bar", bar: "baz", oops: "heh").messages).to eql(
        ['size must be 2']
      )
    end
  end

  context 'using a custom predicate' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def valid_keys?(input)
            input.size == 2 || input.size == 1
          end
        end

        input :hash?, :valid_keys?

        required(:foo).filled
        optional(:bar).filled
      end
    end

    it 'passes when input is valid' do
      expect(schema.(foo: 'bar')).to be_successful
      expect(schema.(foo: 'bar', bar: 'baz')).to be_successful
    end

    it 'fails when one of the root-rules fails' do
      expect(schema.(foo: 'bar', bar: 'baz', oops: 'heh')).to be_failure
    end
  end
end
