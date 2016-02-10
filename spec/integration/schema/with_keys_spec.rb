RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  describe 'defining key-based schema (hash-like)' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email) { |email| email.filled? }

        key(:age) do |age|
          age.none? | (age.int? & age.gt?(18))
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
          phone_numbers.array? { phone_numbers.each(&:str?) }
        end
      end
    end

    let(:input) do
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
        expect(validation.(input.merge(email: '')).messages).to eql(
          email: ['email must be filled']
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validation.(input)).to be_success
      end

      it 'validates presence of an email and min age value' do
        expect(validation.(input.merge(email: '', age: 18))).to match_array([
          [:error, [:input, [:age, 18, [[:key, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:key, [:email, [:predicate, [:filled?, []]]]]]]]]
        ])
      end

      it 'validates presence of the email key and type of age value' do
        attrs = {
          name: 'Jane',
          age: '18',
          address: input[:address], phone_numbers: input[:phone_numbers]
        }

        expect(validation.(attrs)).to match_array([
          [:error, [:input, [:age, "18", [[:key, [:age, [:predicate, [:int?, []]]]]]]]],
          [:error, [:input, [:email, attrs, [[:val, [:email, [:predicate, [:key?, [:email]]]]]]]]]
        ])
      end

      it 'validates presence of the address and phone_number keys' do
        attrs = { email: 'jane@doe.org', age: 19 }

        expect(validation.(attrs)).to match_array([
          [:error, [:input, [:address, attrs, [[:val, [:address, [:predicate, [:key?, [:address]]]]]]]]],
          [:error, [:input, [:phone_numbers, attrs, [[:val, [:phone_numbers, [:predicate, [:key?, [:phone_numbers]]]]]]]]]
        ])
      end

      it 'validates presence of keys under address and min size of the city value' do
        attrs = input.merge(address: { city: 'NY' })

        expect(validation.(attrs)).to match_array([
          [:error, [
            :input, [
              :address, { city: "NY" },
              [
                [:input, [[:address, :city], "NY", [[:key, [[:address, :city], [:predicate, [:min_size?, [3]]]]]]]],
                [:input, [:street, attrs, [[:val, [:street, [:predicate, [:key?, [:street]]]]]]]],
                [:input, [:country, attrs, [[:val, [:country, [:predicate, [:key?, [:country]]]]]]]]
              ]
            ]
          ]]
        ])
      end

      it 'validates address type' do
        expect(validation.(input.merge(address: 'totally not a hash'))).to match_array([
          [:error, [
            :input, [:address, "totally not a hash", [
              [:key, [:address, [:predicate, [:hash?, []]]]]]]]
          ]
        ])
      end

      it 'validates address code and name values' do
        expect(validation.(input.merge(address: input[:address].merge(country: { code: 'US', name: '' })))).to match_array([
          [:error, [
            :input, [
              :address, {city: "NYC", street: "Street 1/2", country: {code: "US", name: ""}},
              [
                [
                  :input, [
                    [:address, :country], { code: 'US', name: '' }, [
                      [
                        :input, [
                          [:address, :country, :name], '', [
                            [:val, [[:address, :country, :name], [:predicate, [:filled?, []]]]]
                          ]
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
        expect(validation.(input.merge(phone_numbers: ['123', 312]))).to match_array([
          [:error, [
            :input, [
              :phone_numbers, ["123", 312],
              [
                [:el, [
                  1,
                  [
                    :input, [
                      :rule, 312, [
                        [:val, [:rule, [:predicate, [:str?, []]]]]
                      ]
                    ]
                  ]
                ]]
              ]
            ]
          ]]
        ])
      end
    end
  end
end
