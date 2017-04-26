RSpec.describe Dry::Validation::Schema, 'arbitrary validation blocks' do
  context 'with a single value' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          option :email_regex, /@/

          def self.messages
            super.merge(en: { errors: { email?: '%{value} looks like an invalid email' } })
          end
        end

        required(:email).filled

        validate(email?: :email) do |value|
          email_regex.match(value)
        end
      end
    end

    it 'returns success for valid input' do
      expect(schema.(email: 'jane@doe.org')).to be_success
    end

    it 'returns failure for invalid input' do
      expect(schema.(email: 'jane')).to be_failure
    end

    it 'adds correct error message' do
      expect(schema.(email: 'jane').messages).to eql(
        email: ['jane looks like an invalid email']
      )
    end

    it 'is not executed when deps are invalid' do
      expect(schema.(email: nil)).to be_failure
    end
  end

  context 'with more than one value' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          def self.messages
            super.merge(en: { errors: { email_required: 'provide email' }})
          end
        end

        required(:email).maybe(:str?)
        required(:newsletter).value(:bool?)

        validate(email_required: %i[newsletter email]) do |newsletter, email|
          if newsletter == true
            !email.nil?
          else
            true
          end
        end
      end
    end

    it 'returns success for valid input' do
      expect(schema.(newsletter: false, email: nil)).to be_success
      expect(schema.(newsletter: true, email: 'jane@doe.org')).to be_success
    end

    it 'returns failure for invalid input' do
      expect(schema.(newsletter: true, email: nil)).to be_failure
    end

    it 'adds correct error message' do
      expect(schema.(newsletter: true, email: nil).errors).to eql(
        email_required: ['provide email']
      )
    end

    it 'is not executed when deps are invalid' do
      expect(schema.(newsletter: 'oops', email: '').errors).to eql(
        newsletter: ['must be boolean']
      )
    end
  end

  context 'with more than one validation' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          option :email_regex, /@/

          def self.messages
            super.merge(en: {
              errors: {
                email?:        '%{value} looks like an invalid email',
                google_email?: '%{value} is not a google email'
              } })
          end
        end

        required(:email).filled

        validate(email?: :email) do |value|
          email_regex.match(value)
        end

        validate(google_email?: :email) do |value|
          value.end_with?('@google.com')
        end
      end
    end

    it 'returns errors message for both validate' do
      expect(schema.(email: 'jane').messages).to eql(
        email: [
          'jane looks like an invalid email',
          'jane is not a google email'
        ]
      )
    end
  end
end
