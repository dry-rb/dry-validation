RSpec.describe Dry::Validation::Schema, 'defining key-based schema' do
  subject(:validate) { schema.new }

  describe 'with a flat structure' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:email).required

        key(:age) do |age|
          age.none? | (age.int? & age.gt?(18))
        end
      end
    end

    it 'passes when input is valid' do
      expect(validate.(email: 'jane@doe', age: 19)).to be_success
      expect(validate.(email: 'jane@doe', age: nil)).to be_success
    end

    it 'fails when input is not valid' do
      expect(validate.(email: 'jane@doe', age: 17)).to_not be_success
    end
  end

  describe 'with nested structures' do
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
        expect(validate.(input.merge(email: '')).messages).to eql(
          email: ['email must be filled']
        )
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validate.(input)).to be_success
      end

      it 'validates presence of an email and min age value' do
        expect(validate.(input.merge(email: '', age: 18))).to match_array([
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

        expect(validate.(attrs)).to match_array([
          [:error, [:input, [:age, "18", [[:key, [:age, [:predicate, [:int?, []]]]]]]]],
          [:error, [:input, [:email, attrs, [[:val, [:email, [:predicate, [:key?, [:email]]]]]]]]]
        ])
      end

      it 'validates presence of the address and phone_number keys' do
        attrs = { email: 'jane@doe.org', age: 19 }

        expect(validate.(attrs)).to match_array([
          [:error, [:input, [:address, attrs, [[:val, [:address, [:predicate, [:key?, [:address]]]]]]]]],
          [:error, [:input, [:phone_numbers, attrs, [[:val, [:phone_numbers, [:predicate, [:key?, [:phone_numbers]]]]]]]]]
        ])
      end

      it 'validates presence of keys under address and min size of the city value' do
        attrs = input.merge(address: { city: 'NY' })

        expect(validate.(attrs)).to match_array([
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
        expect(validate.(input.merge(address: 'totally not a hash'))).to match_array([
          [:error, [
            :input, [:address, "totally not a hash", [
              [:key, [:address, [:predicate, [:hash?, []]]]]]]]
          ]
        ])
      end

      it 'validates address code and name values' do
        expect(validate.(input.merge(address: input[:address].merge(country: { code: 'US', name: '' })))).to match_array([
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
        expect(validate.(input.merge(phone_numbers: ['123', 312]))).to match_array([
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
