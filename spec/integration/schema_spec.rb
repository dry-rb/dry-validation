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
        expect(validation.(input.merge(email: '')).messages).to match_array([
          [:email, [['email must be filled'], '']]
        ])
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validation.(input)).to be_empty
      end

      it 'validates presence of an email and min age value' do
        expect(validation.(input.merge(email: '', age: 18))).to match_array([
          [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]]
        ])
      end

      it 'validates presence of the email key and type of age value' do
        expect(validation.(name: 'Jane', age: '18', address: input[:address], phone_numbers: input[:phone_numbers])).to match_array([
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
        expect(validation.(input.merge(address: { city: 'NY' }))).to match_array([
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
        expect(validation.(input.merge(address: 'totally not a hash'))).to match_array([
          [:error, [:input, [:address, "totally not a hash", [[:val, [:address, [:predicate, [:hash?, []]]]]]]]]
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
        expect(validation.(input.merge(phone_numbers: ['123', 312]))).to match_array([
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

  describe 'defining attr-based schema (model-like)' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        attr(:email) { |email| email.filled? }

        attr(:age) do |age|
          age.none? | (age.int? & age.gt?(18))
        end

        attr(:address) do |address|
          address.attr(:city) do |city|
            city.min_size?(3)
          end

          address.attr(:street) do |street|
            street.filled?
          end

          address.attr(:country) do |country|
            country.attr(:name, &:filled?)
            country.attr(:code, &:filled?)
          end
        end

        attr(:phone_numbers) do |phone_numbers|
          phone_numbers.array? { phone_numbers.each(&:str?) }
        end
      end
    end

    let(:input_data) do
      {
        email: 'jane@doe.org',
        age: 19,
        address: { city: 'NYC', street: 'Street 1/2', country: { code: 'US', name: 'USA' } },
        phone_numbers: [
          '123456', '234567'
        ]
      }.freeze
    end

    def input(data = input_data)
      struct_from_hash(data)
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.(input(input_data.merge(email: ''))).messages).to match_array([
          [:email, [["email must be filled"], '']]
        ])
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        expect(validation.(input)).to be_empty
      end

      it 'validates presence of an email and min age value' do
        expect(validation.(input(input_data.merge(email: '', age: 18)))).to match_array([
          [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]]
        ])
      end

      it 'validates presence of the email attr and type of age value' do
        input_object = input(input_data.reject { |k, v| k == :email }.merge(age: '18'))

        expect(validation.(input_object)).to match_array([
          [:error, [:input, [:age, "18", [[:val, [:age, [:predicate, [:int?, []]]]]]]]],
          [:error, [:input, [:email, input_object, [[:attr, [:email, [:predicate, [:attr?, [:email]]]]]]]]]
        ])
      end

      it 'validates presence of the address and phone_number keys' do
        input_object = input(email: 'jane@doe.org', age: 19)

        expect(validation.(input_object)).to match_array([
          [:error, [
            :input, [
              :address, input_object,
              [
                [:attr, [:address, [:predicate, [:attr?, [:address]]]]]
              ]
            ]
          ]],
          [:error, [
            :input, [
              :phone_numbers, input_object,
              [
                [:attr, [:phone_numbers, [:predicate, [:attr?, [:phone_numbers]]]]]
              ]
            ]
          ]]
        ])
      end

      it 'validates presence of keys under address and min size of the city value' do
        address = { city: 'NY' }
        input_object = input(input_data.merge(address: address))
        address_object = input_object.address.class.from_hash(address)

        expect(validation.(input_object)).to match_array([
          [:error, [
            :input, [
              :address, address_object,
              [
                [:input, [:city, "NY", [[:val, [:city, [:predicate, [:min_size?, [3]]]]]]]],
                [:input, [:street, address_object, [[:attr, [:street, [:predicate, [:attr?, [:street]]]]]]]],
                [:input, [:country, address_object, [[:attr, [:country, [:predicate, [:attr?, [:country]]]]]]]]
              ]
            ]
          ]]
        ])
      end

      it 'validates address code and name values' do
        input_object = input(input_data.merge(address: input_data[:address].merge(country: { code: 'US', name: '' })))

        country_object = input_object.address.country.class.from_hash(code: "US", name: "")

        expect(validation.(input_object)).to match_array([
          [:error, [
            :input, [
              :address, input_object.address.class.from_hash(city: "NYC", street: "Street 1/2", country: country_object),
              [
                [
                  :input, [
                    :country, country_object, [
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
        input_object = input(input_data.merge(phone_numbers: ['123', 312]))

        expect(validation.(input_object)).to match_array([
          [:error, [
            :input, [
              :phone_numbers, ["123", 312],[
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
