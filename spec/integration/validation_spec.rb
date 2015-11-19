RSpec.describe Dry::Validation do
  let(:schema) do
    Class.new(Dry::Validation::Schema) do
      key(:email) { |email| email.filled? }

      key(:age) do |age|
        age.int? & age.gt?(18)
      end

      key(:address) do |address|
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

      key(:phone_numbers) do |phone_numbers|
        phone_numbers.each(&:str?)
      end
    end
  end

  describe 'defining schema' do
    let(:validation) { schema.new }

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

    it 'passes when attributes are valid' do
      expect(validation.(attrs)).to be_empty
    end

    it 'validates presence of an email and min age value' do
      expect(validation.(attrs.merge(email: '', age: 18))).to match_array([
        [:error, [[:input, ""], [:rule, [:email, [:predicate, [:filled?, []]]]]]],
        [:error, [[:input, 18], [:rule, [:age, [:predicate, [:gt?, [18]]]]]]]
      ])
    end

    it 'validates presence of the email key and type of age value' do
      expect(validation.(name: 'Jane', age: '18', address: attrs[:address], phone_numbers: attrs[:phone_numbers])).to match_array([
        [:error, [[:input, nil], [:rule, [:email, [:predicate, [:key?, [:email]]]]]]],
        [:error, [[:input, "18"], [:rule, [:age, [:predicate, [:int?, []]]]]]]
      ])
    end

    it 'validates presence of the address and phone_number keys' do
      expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
        [:error, [[:input, nil], [:rule, [:address, [:predicate, [:key?, [:address]]]]]]],
        [:error, [[:input, nil], [:rule, [:phone_numbers, [:predicate, [:key?, [:phone_numbers]]]]]]]
      ])
    end

    it 'validates presence of keys under address and min size of the city value' do
      expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
        [:error, [
          [:input, { city: "NY" }],
          [
            :rule, [
              :address, [
                :set, [
                  [
                    [:rule, [:city, [:predicate, [:key?, [:city]]]]],
                    [
                      [:rule, [:city, [:predicate, [:min_size?, [3]]]]]
                    ]
                  ],
                  [
                    [:rule, [:street, [:predicate, [:key?, [:street]]]]],
                    [
                      [:rule, [:street, [:predicate, [:filled?, []]]]]
                    ]
                  ],
                  [
                    [:rule, [:country, [:predicate, [:key?, [:country]]]]],
                    [
                      [
                        :rule, [
                          :country, [
                            :set, [
                              [
                                [:rule, [:name, [:predicate, [:key?, [:name]]]]],
                                [
                                  [:rule, [:name, [:predicate, [:filled?, []]]]]]
                              ],
                              [
                                [:rule, [:code, [:predicate, [:key?, [:code]]]]],
                                [
                                  [:rule, [:code, [:predicate, [:filled?, []]]]]
                                ]
                              ]
                            ]
                          ]
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

    it 'validates address code and name values' do
      expect(validation.(attrs.merge(address: attrs[:address].merge(country: { code: 'US', name: '' })))).to match_array([
        [:error, [
          [:input, { city: "NYC", street: "Street 1/2", country: { code: "US", name: "" }}],
          [
            :rule, [
              :address, [
                :set, [
                  [
                    [:rule, [:country, [:predicate, [:key?, [:country]]]]],
                    [
                      [
                        :rule, [
                          :country, [
                            :set, [
                              [
                                [:rule, [:name, [:predicate, [:key?, [:name]]]]],
                                [
                                  [:rule, [:name, [:predicate, [:filled?, []]]]]
                                ]
                              ],
                              [
                                [:rule, [:code, [:predicate, [:key?, [:code]]]]],
                                [
                                  [:rule, [:code, [:predicate, [:filled?, []]]]]
                                ]
                              ]
                            ]
                          ]
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
  end
end
