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

    xit 'fails when 1-level key is missing' do
      expect(schema.(foo: {}).messages).to eql(foo: { bar: ["is missing"] })
    end

    xit 'fails when 2-level key has invalid value' do
      expect(schema.(foo: { bar: { baz: '' }}).messages).to eql(
        foo: { bar: { baz: ['must be filled'] } }
      )
    end
  end
end
