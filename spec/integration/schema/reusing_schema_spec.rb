RSpec.describe 'Reusing schemas' do
  subject(:schema) do
    Dry::Validation.Schema do
      required(:city).filled

      required(:location).schema(LocationSchema)
    end
  end

  before do
    LocationSchema = Dry::Validation.Schema do
      configure { config.input_processor = :form }

      required(:lat).filled(:float?)
      required(:lng).filled(:float?)
    end
  end

  after do
    Object.send(:remove_const, :LocationSchema)
  end

  it 're-uses existing schema' do
    expect(schema.(city: 'NYC', location: { lat: 1.23, lng: 45.6 })).to be_success

    expect(schema.(city: 'NYC', location: { lat: nil, lng: '45.6' }).messages).to eql(
      location: {
        lat: ['must be filled'],
        lng: ['must be a float']
      }
    )
  end
end
