RSpec.describe Dry::Validation do
  include_context 'user validator'
  include_context 'embedded user validator'
  include_context 'users validator'

  describe '#errors' do
    subject! { validator.errors }

    context 'flat validator' do
      context 'with valid attributes' do
        let(:validator) { user_validator.new(valid_user_attributes) }

        it { is_expected.to be_empty }
      end

      context 'with invalid attributes' do
        let(:validator) { user_validator.new(invalid_user_attributes) }

        it do
          is_expected.to eq(
            title: [
              {
                code: 'inclusion',
                value: invalid_title,
                options: %w(Mr Mrs Miss Ms Dr)
              }
            ],
            first_name: [
              {
                code: 'presence',
                value: invalid_first_name,
                options: true
              }
            ],
            last_name: [
              {
                code: 'presence',
                value: invalid_last_name,
                options: true
              }
            ],
            username: [
              {
                code: 'presence',
                value: invalid_username,
                options: true
              }
            ]
          )
        end
      end
    end

    context 'embedded validator' do
      context 'with valid attributes' do
        let(:validator) { embedded_user_validator.new(valid_embedded_user_attributes) }

        it { is_expected.to be_empty }
      end

      context 'with invalid attributes' do
        let(:validator) { embedded_user_validator.new(invalid_embedded_user_attributes) }

        it do
          is_expected.to eq(
            user: [
              {
                code: 'embedded',
                errors: {
                  title: [
                    {
                      code: 'inclusion',
                      value: invalid_title,
                      options: %w(Mr Mrs Miss Ms Dr)
                    }
                  ],
                  first_name: [
                    {
                      code: 'presence',
                      value: invalid_first_name,
                      options: true
                    }
                  ],
                  last_name: [
                    {
                      code: 'presence',
                      value: invalid_last_name,
                      options: true
                    }
                  ],
                  username: [
                    {
                      code: 'presence',
                      value: invalid_username,
                      options: true
                    }
                  ]
                },
                value: invalid_user_attributes,
                options: {}
              }
            ]
          )
        end
      end
    end

    context 'each validator' do
      context 'with valid attributes' do
        let(:validator) { users_validator.new(valid_users_attributes) }

        it { is_expected.to be_empty }
      end

      context 'with invalid attributes' do
        let(:validator) { users_validator.new(invalid_users_attributes) }

        it do
          is_expected.to eq(
            users: [
              {
                code: 'each',
                errors: [
                  {
                    title: [
                      {
                        code: 'inclusion',
                        value: invalid_title,
                        options: %w(Mr Mrs Miss Ms Dr)
                      }
                    ],
                    first_name: [
                      {
                        code: 'presence',
                        value: invalid_first_name,
                        options: true
                      }
                    ],
                    last_name: [
                      {
                        code: 'presence',
                        value: invalid_last_name,
                        options: true
                      }
                    ],
                    username: [
                      {
                        code: 'presence',
                        value: invalid_username,
                        options: true
                      }
                    ]
                  }
                ],
                value: [invalid_user_attributes],
                options: {}
              }
            ]
          )
        end
      end
    end
  end
end
