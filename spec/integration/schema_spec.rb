RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email) { |email| email.filled? }

        key(:age) do |age|
          age.int? & age.gt?(18)
        end

        key(:address) do |address|
          address.hash? do
            address.key(:city) do |city|
              city.min_size?(3)
            end

            address.key(:street) do |street|
              street.filled?
            end

            address.key(:country) do |country|
              country.key(:name, &:filled?)
              country.key(:code, &:filled?)
            end
          end
        end

        key(:phone_numbers) do |phone_numbers|
          phone_numbers.each(&:str?)
        end
      end
    end

    let(:attrs) do
      {
        email: 'jane@doe.org',
        age: 19,
        address: { city: 'NYC', street: 'Street 1/2', country: { code: 'US', name: 'USA' } },
        phone_numbers: [
          '123456', '234567'
        ]
      }.freeze
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.messages(attrs.merge(email: ''))).to eql([
          [:email, ["email must be filled"]]
        ])
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validation.(attrs)).to be_empty
      end

      it 'validates presence of an email and min age value' do
        expect(validation.(attrs.merge(email: '', age: 18))).to match_array([
          [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]]
        ])
      end

      it 'validates presence of the email key and type of age value' do
        expect(validation.(name: 'Jane', age: '18', address: attrs[:address], phone_numbers: attrs[:phone_numbers])).to match_array([
          [:error, [:input, [:age, "18", [[:val, [:age, [:predicate, [:int?, []]]]]]]]],
          [:error, [:input, [:email, nil, [[:key, [:email, [:predicate, [:key?, [:email]]]]]]]]]
        ])
      end

      it 'validates presence of the address and phone_number keys' do
        expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
          [:error, [:input, [:address, nil, [[:key, [:address, [:predicate, [:key?, [:address]]]]]]]]],
          [:error, [:input, [:phone_numbers, nil, [[:key, [:phone_numbers, [:predicate, [:key?, [:phone_numbers]]]]]]]]]
        ])
      end

      it 'validates presence of keys under address and min size of the city value' do
        expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
          [:error, [
            :input, [
              :address, {city: "NY"},
              [
                [:input, [:city, "NY", [[:val, [:city, [:predicate, [:min_size?, [3]]]]]]]],
                [:input, [:street, nil, [[:key, [:street, [:predicate, [:key?, [:street]]]]]]]],
                [:input, [:country, nil, [[:key, [:country, [:predicate, [:key?, [:country]]]]]]]]
              ]
            ]
          ]]
        ])
      end

      it 'validates address type' do
        expect(validation.(attrs.merge(address: 'totally not a hash'))).to match_array([
          [:error, [:input, [:address, "totally not a hash", [[:val, [:address, [:predicate, [:hash?, []]]]]]]]]
        ])
      end

      it 'validates address code and name values' do
        expect(validation.(attrs.merge(address: attrs[:address].merge(country: { code: 'US', name: '' })))).to match_array([
          [:error, [
            :input, [
              :address, {city: "NYC", street: "Street 1/2", country: {code: "US", name: ""}},
              [
                [
                  :input, [
                    :country, {code: "US", name: ""}, [
                      [
                        :input, [
                          :name, "", [[:val, [:name, [:predicate, [:filled?, []]]]]]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]]
        ])
      end

      it 'validates each phone number' do
        expect(validation.(attrs.merge(phone_numbers: ['123', 312]))).to match_array([
          [:error, [
            :input, [
              :phone_numbers, ["123", 312],
              [
                [
                  :input, [
                    :phone_numbers, 312, [
                      [:val, [:phone_numbers, [:predicate, [:str?, []]]]]
                    ]
                  ]
                ]
              ]
            ]
          ]]
        ])
      end
    end
  end
end
