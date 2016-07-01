RSpec.describe 'Macros #input' do
  subject(:schema) do
    Dry::Validation.Schema do
      input :hash?

      required(:foo).filled
    end
  end

  it 'passes when input is valid' do
    expect(schema.(foo: "bar")).to be_successful
  end

  it 'prepends a rule for the input' do
    expect(schema.(nil).messages).to eql(["must be a hash"])
  end

  it 'applies other rules when input has expected type' do
    expect(schema.(foo: '').messages).to eql(foo: ["must be filled"])
  end
end
