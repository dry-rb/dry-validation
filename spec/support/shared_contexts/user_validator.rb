RSpec.shared_context 'user validator' do
  let(:user_validator_rules) do
    {
      title: {
        inclusion: %w(Mr Mrs Miss Ms Dr)
      },
      first_name: {
        presence: true
      },
      last_name: {
        presence: true
      },
      username: {
        presence: true
      }
    }
  end
  let(:user_validator) do
    Class.new { include Dry::Validation }.tap do |klass|
      klass.rules << user_validator_rules
    end
  end
  let(:title) { %w(Mr Mrs Miss Ms Dr).sample }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:username) { Faker::Lorem.word }
  let(:valid_user_attributes) do
    {
      title: title,
      first_name: first_name,
      last_name: last_name,
      username: username
    }
  end
  let(:invalid_title) { Faker::Lorem.word }
  let(:invalid_first_name) { '' }
  let(:invalid_last_name) { '' }
  let(:invalid_username) { '' }
  let(:invalid_user_attributes) do
    {
      title: invalid_title,
      first_name: invalid_first_name,
      last_name: invalid_last_name,
      username: invalid_username
    }
  end
end
