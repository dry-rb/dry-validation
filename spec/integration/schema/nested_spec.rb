RSpec.describe Schema, 'using nested schemas' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Schema) do
      key(:location) do |loc|
        loc.key(:lat).required
        loc.key(:lng).required
      end
    end
  end

  it 'passes when location has lat and lng filled' do
    expect(validate.(location: { lat: 1.23, lng: 4.56 })).to be_success
  end

  it 'fails when location has missing lat' do
    expect(validate.(location: { lng: 4.56 })).to match_array([
      [
        :error, [
          :input, [
            :location, { lng: 4.56 },
            [
              [:input, [:lat, nil, [[:key, [:lat, [:predicate, [:key?, [:lat]]]]]]]]
            ]
          ]
        ]
      ]
    ])
  end
end
