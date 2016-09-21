RSpec.shared_context :message_compiler do
  subject(:compiler) { Dry::Validation::MessageCompiler.new(messages) }

  let(:messages) do
    Dry::Validation::Messages.default
  end

  let(:result) do
    compiler.public_send(visitor, node)
  end
end
