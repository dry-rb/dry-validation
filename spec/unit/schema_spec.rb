require 'dry/validation/messages/i18n'

RSpec.describe Schema do
  describe '.messages' do
    context 'with default setting' do
      let(:schema) do
        Class.new(Schema)
      end

      it 'returns default yaml messages' do
        expect(schema.messages).to be_instance_of(Messages::YAML)
      end
    end

    context 'with i18n setting' do
      let(:schema) do
        Class.new(Schema) { configure { config.messages = :i18n } }
      end

      it 'returns default i18n messages' do
        expect(schema.messages).to be_instance_of(Messages::I18n)
      end
    end

    context 'with an invalid setting' do
      let(:schema) do
        Class.new(Schema) { configure { config.messages = :oops } }
      end

      it 'returns default i18n messages' do
        expect { schema.messages }.to raise_error(RuntimeError, /oops/)
      end
    end
  end
end
