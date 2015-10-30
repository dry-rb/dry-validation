RSpec.shared_context 'embedded user validator' do
  include_context 'user validator'

  let(:embedded_user_validator) do
    Class.new { include Dry::Validation }.tap do |klass|
      klass.rules << { user: { embedded: user_validator } }
    end
  end
  let(:valid_embedded_user_attributes) { { user: valid_user_attributes } }
  let(:invalid_embedded_user_attributes) { { user: invalid_user_attributes } }
end
