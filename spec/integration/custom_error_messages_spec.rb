require 'dry/validation/messages/i18n'

RSpec.describe Dry::Validation do
  shared_context 'schema with customized messages' do
    describe '#messages' do
      it 'returns compiled error messages' do
        expect(schema.(email: '').messages).to eql(
          email: ['Please provide your email']
        )
      end
    end
  end

  context 'yaml' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        end

        required(:email, &:filled?)
      end
    end

    include_context 'schema with customized messages'
  end

  context 'i18n' do
    context 'with custom messages set globally' do
      before do
        I18n.load_path << SPEC_ROOT.join('fixtures/locales/en.yml')
        I18n.backend.load_translations
      end

      subject(:schema) do
        Dry::Validation.Schema do
          configure do
            config.messages = :i18n
          end

          required(:email, &:filled?)
        end
      end

      include_context 'schema with customized messages'
    end
  end

  context 'custom messages' do
    context 'with invalid settings' do
      it 'should return error when config.custom_messages is nil' do
        expect do
          Dry::Validation.Schema do
            configure do
              config.messages = :custom
              config.custom_messages = nil
            end

            required(:email, &:filled?)
          end
        end.to raise_error RuntimeError
      end
    end

    context 'with valid settings' do
      subject(:schema) do
        rspec_context = self
        Dry::Validation.Schema do
          configure do
            config.messages = :custom
            config.custom_messages = rspec_context.custom_messages
          end

          required(:email, &:filled?)
        end
      end

      let(:custom_messages) do
        obj = Object.new
        obj.define_singleton_method(:default_locale) { :en }
        obj
      end

      context 'custom messages object returnin string' do
        before :each do
          custom_messages.define_singleton_method(:[]) do |*_|
            'Please provide your email'
          end
        end

        include_context 'schema with customized messages'
      end

      context 'custom messages object returning custom message object' do
        let(:message) do
          obj = Object.new
          obj.define_singleton_method(:%) { |_| self }
          obj
        end

        before :each do
          rspec_context = self
          custom_messages.define_singleton_method(:[]) do |*_|
            rspec_context.message
          end
        end

        it 'returns compiled error messages' do
          expect(schema.(email: '').messages).to eql(
            email: [message]
          )
        end
      end

      context 'custom messages object which is subclass of ' \
              'Dry::Validation::Messages::Abstract' do
        let(:message) do
          obj = Object.new
          obj.define_singleton_method(:%) { |_| self }
          obj
        end

        let(:custom_messages) do
          rspec_context = self
          obj = Class.new(Dry::Validation::Messages::Abstract).new
          obj.define_singleton_method(:get) { |*_| rspec_context.message }
          obj.define_singleton_method(:key?) { |*_| true }
          obj.define_singleton_method(:valid_message?) { |*_| true }
          obj
        end

        it 'returns compiled error messages' do
          expect(schema.(email: '').messages).to eql(
            email: [message]
          )
        end
      end
    end
  end
end
