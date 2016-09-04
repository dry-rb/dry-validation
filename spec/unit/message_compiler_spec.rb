RSpec.describe MessageCompiler, '#call' do
  subject(:message_compiler) { MessageCompiler.new( Messages.default ) }

  it 'returns an empty hash when there are no errors' do
    expect(message_compiler.([])).to be_empty
  end
end
