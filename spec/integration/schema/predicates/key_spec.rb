#see: https://github.com/dry-rb/dry-validation/issues/127
RSpec.describe 'Predicates: Key' do
  context 'with required' do
    xit "should raise error" do
      expect { Dry::Validation.Schema do
        required(:foo) { key? }
      end }.to raise_error InvalidSchemaError
    end
  end

  context 'with optional' do
    subject(:schema) do
      xit "should raise error" do
        expect { Dry::Validation.Schema do
          optional(:foo) { key? }
        end }.to raise_error InvalidSchemaError
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            required(:foo).value(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with filled' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            required(:foo).filled(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            required(:foo).maybe(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            optional(:foo).value(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with filled' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            optional(:foo).filled(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        xit "should raise error" do
          expect { Dry::Validation.Schema do
            optional(:foo).maybe(:key?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end
  end
end
