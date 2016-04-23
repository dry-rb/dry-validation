RSpec.describe 'Inheriting schema' do
  subject(:schema) do
    Dry::Validation.Schema(base_schema) do
      required(:location).schema do
        required(:lat).filled(:float?)
        required(:lng).filled(:float?)
      end
    end
  end

  let(:base_schema) do
    Dry::Validation.Schema do
      required(:city).filled
    end
  end

  it 'inherits rules from parent schema' do
    expect(schema.(city: 'NYC', location: { lat: 1.23, lng: 45.6 })).to be_success

    expect(schema.(city: '', location: { lat: 1.23, lng: 45.6 }).messages).to eql(
      city: ['must be filled']
    )

    expect(schema.(city: 'NYC', location: { lat: nil, lng: '45.6' }).messages).to eql(
      location: {
        lat: ['must be filled'],
        lng: ['must be a float']
      }
    )
  end
end
