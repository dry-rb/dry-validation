RSpec.shared_context 'users validator' do
  include_context 'user validator'

  let(:users_validator) do
    Class.new { include Dry::Validation }.tap do |klass|
      klass.rules << { users: { each: user_validator } }
    end
  end
  let(:valid_users_attributes) { { users: [valid_user_attributes] } }
  let(:invalid_users_attributes) { { users: [invalid_user_attributes] } }
end
