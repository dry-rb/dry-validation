require 'dry/validation/input_type_compiler'

RSpec.describe Dry::Validation::InputTypeCompiler, '#call' do
  subject(:compiler) { Dry::Validation::InputTypeCompiler.new }

  let(:rule_ast) do
    [
      [
        :and, [
          [:key, [:email, [:predicate, [:key?, [:email]]]]],
          [
            :and, [
              [:val, [:email, [:predicate, [:str?, []]]]],
              [:val, [:email, [:predicate, [:filled?, []]]]]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:age, [:predicate, [:key?, [:age]]]]],
          [
            :or, [
              [:val, [:age, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:val, [:age, [:predicate, [:int?, []]]]],
                  [:val, [:age, [:predicate, [:filled?, []]]]]
                ]
              ]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:key, [:address, [:predicate, [:key?, [:address]]]]],
          [:val, [:address, [:predicate, [:str?, []]]]]
        ]
      ]
    ].map(&:to_ary)
  end

  let(:params) do
    { 'email' => 'jane@doe.org', 'age' => '20', 'address' => 'City, Street 1/2' }
  end

  it 'builds an input dry-data type' do
    input_type = compiler.(rule_ast)

    result = input_type[params]

    expect(result).to eql(email: 'jane@doe.org', age: 20, address: 'City, Street 1/2')
  end

  it 'supports int? => "form.int"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:age, [:predicate, [:key?, [:age]]]]],
          [:val, [:age, [:predicate, [:int?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['age' => '21']).to eql(age: 21)
  end

  it 'supports none? => "form.int"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:age, [:predicate, [:key?, [:age]]]]],
          [
            :or, [
              [:val, [:age, [:predicate, [:none?, []]]]],
              [:val, [:age, [:predicate, [:int?, []]]]],
            ]
          ]
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['age' => '']).to eql(age: nil)
    expect(input_type['age' => '21']).to eql(age: 21)
  end

  it 'supports float? => "form.float"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:lat, [:predicate, [:key?, [:lat]]]]],
          [:val, [:lat, [:predicate, [:float?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['lat' => '21.12']).to eql(lat: 21.12)
  end

  it 'supports decimal? => "form.decimal"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:lat, [:predicate, [:key?, [:lat]]]]],
          [:val, [:lat, [:predicate, [:decimal?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['lat' => '21.12']).to eql(lat: 21.12.to_d)
  end

  it 'supports date? => "form.date"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:bday, [:predicate, [:key?, [:bday]]]]],
          [:val, [:bday, [:predicate, [:date?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['bday' => '2012-01-23']).to eql(bday: Date.new(2012, 1, 23))
  end

  it 'supports date_time? => "form.date_time"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:bday, [:predicate, [:key?, [:bday]]]]],
          [:val, [:bday, [:predicate, [:date_time?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['bday' => '2012-01-23 11:07']).to eql(bday: DateTime.new(2012, 1, 23, 11, 7))
  end

  it 'supports time? => "form.time"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:bday, [:predicate, [:key?, [:bday]]]]],
          [:val, [:bday, [:predicate, [:time?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['bday' => '2012-01-23 11:07']).to eql(bday: Time.new(2012, 1, 23, 11, 7))
  end

  it 'supports time? => "form.time"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:bday, [:predicate, [:key?, [:bday]]]]],
          [:val, [:bday, [:predicate, [:time?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['bday' => '2012-01-23 11:07']).to eql(bday: Time.new(2012, 1, 23, 11, 7))
  end

  it 'supports bool? => "form.bool"' do
    rule_ast = [
      [
        :and,
        [
          [:key, [:admin, [:predicate, [:key?, [:admin]]]]],
          [:val, [:admin, [:predicate, [:bool?, []]]]],
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['admin' => 'true']).to eql(admin: true)
    expect(input_type['admin' => 'false']).to eql(admin: false)
  end

  it 'supports each rule' do
    rule_ast = [
      [
        :and, [
          [:key, [:author, [:predicate, [:key?, []]]]],
          [
            :set, [
              :author, [
                [
                  :and, [
                    [:key, [:books, [:predicate, [:key?, []]]]],
                    [
                      :each, [
                        :books,
                        [
                          :set, [
                            :books, [
                              [
                                :and, [
                                  [:key, [:published, [:predicate, [:key?, []]]]],
                                  [:val, [:published, [:predicate, [:bool?, []]]]]
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
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['author' => { 'books' => [{ 'published' => 'true' }] }]).to eql(
      author: { books: [published: true] }
    )

    expect(input_type['author' => { 'books' => [{ 'published' => 'false' }] }]).to eql(
      author: { books: [published: false] }
    )
  end

  it 'supports array? with an each rule' do
    rule_ast = [
      [
        :and, [
          [:key, [:ids, [:predicate, [:key?, []]]]],
          [
            :and, [
              [:val, [:ids, [:predicate, [:array?, []]]]],
              [:each, [:ids, [:val, [:ids, [:predicate, [:int?, []]]]]]]
            ]
          ]
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type.('ids' => 'oops')).to eql(ids: 'oops')

    expect(input_type.('ids' => %w(1 2 3))).to eql(ids: [1, 2, 3])
  end

  it 'supports hash? with a set rule' do
    rule_ast = [
      [
        :and, [
          [:key, [:address, [:predicate, [:key?, []]]]],
          [
            :and, [
              [:val, [:address, [:predicate, [:hash?, []]]]],
              [
                :set, [
                  :address, [
                    [
                      :and, [
                        [:key, [:street, [:predicate, [:key?, []]]]],
                        [:val, [:street, [:predicate, [:filled?, []]]]]
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

    input_type = compiler.(rule_ast)

    expect(input_type.('address' => 'oops')).to eql(address: 'oops')

    expect(input_type.('address' => { 'street' => 'ok' })).to eql(
      address: { street: 'ok' }
    )
  end
end
