#see: https://github.com/dry-rb/dry-validation/issues/127
RSpec.describe 'Predicates: Key' do
  context 'inferred from required/optional macros' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).value(:str?)
        optional(:bar).value(:int?)
      end
    end

    it 'uses key? predicate for required' do
      expect(schema.({}).messages(full: true)).to eql(foo: ['foo is missing'])
      expect(schema.({}).messages).to eql(foo: ['is missing'])
    end
  end

  context 'with required' do
    it "raises error" do
      expect { Dry::Validation.Schema do
        required(:foo) { key? }
      end }.to raise_error InvalidSchemaError
    end
  end

  context 'with optional' do
    subject(:schema) do
      it "raises error" do
        expect { Dry::Validation.Schema do
          optional(:foo) { key? }
        end }.to raise_error InvalidSchemaError
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            required(:foo).value(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with filled' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            required(:foo).filled(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            required(:foo).maybe(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            optional(:foo).value(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with filled' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            optional(:foo).filled(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            optional(:foo).maybe(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end
  end
end
