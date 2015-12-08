RSpec.describe ErrorCompiler, '#call' do
  subject(:error_compiler) { ErrorCompiler.new({}) }

  it 'returns an empty hash when there are no errors' do
    expect(error_compiler.([])).to be(ErrorCompiler::DEFAULT_RESULT)
  end
end
