require 'dry/validation/input_type_compiler'

RSpec.describe Dry::Validation::InputTypeCompiler, '#call' do
  subject(:compiler) { Dry::Validation::InputTypeCompiler.new }

  let(:rule_ast) do
    [
      [
        :and, [
          [:val, [:predicate, [:key?, [:email]]]],
          [
            :and, [
              [:key, [:email, [:predicate, [:str?, []]]]],
              [:key, [:email, [:predicate, [:filled?, []]]]]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:val, [:predicate, [:key?, [:age]]]],
          [
            :or, [
              [:key, [:age, [:predicate, [:none?, []]]]],
              [
                :and, [
                  [:key, [:age, [:predicate, [:int?, []]]]],
                  [:key, [:age, [:predicate, [:filled?, []]]]]
                ]
              ]
            ]
          ]
        ]
      ],
      [
        :and, [
          [:val, [:predicate, [:key?, [:address]]]],
          [:key, [:address, [:predicate, [:str?, []]]]]
        ]
      ]
    ]
  end

  let(:output) do
    { 'email' => 'jane@doe.org', 'age' => '20', 'address' => 'City, Street 1/2' }
  end

  it 'builds an input dry-data type' do
    input_type = compiler.(rule_ast)

    result = input_type[output]

    expect(result).to eql(email: 'jane@doe.org', age: 20, address: 'City, Street 1/2')
  end

  it 'supports int? => "form.int"' do
    rule_ast = [
      [
        :and,
        [
          [:val, [:predicate, [:key?, [:age]]]],
          [:key, [:age, [:predicate, [:int?, []]]]],
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
          [:val, [:predicate, [:key?, [:age]]]],
          [
            :or, [
              [:key, [:age, [:predicate, [:none?, []]]]],
              [:key, [:age, [:predicate, [:int?, []]]]],
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
          [:val, [:predicate, [:key?, [:lat]]]],
          [:key, [:lat, [:predicate, [:float?, []]]]],
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
          [:val, [:predicate, [:key?, [:lat]]]],
          [:key, [:lat, [:predicate, [:decimal?, []]]]],
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
          [:val, [:predicate, [:key?, [:bday]]]],
          [:key, [:bday, [:predicate, [:date?, []]]]],
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
          [:val, [:predicate, [:key?, [:bday]]]],
          [:key, [:bday, [:predicate, [:date_time?, []]]]],
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
          [:val, [:predicate, [:key?, [:bday]]]],
          [:key, [:bday, [:predicate, [:time?, []]]]],
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
          [:val, [:predicate, [:key?, [:bday]]]],
          [:key, [:bday, [:predicate, [:time?, []]]]],
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
          [:val, [:predicate, [:key?, [:admin]]]],
          [:key, [:admin, [:predicate, [:bool?, []]]]],
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
          [:val, [:predicate, [:key?, [:author]]]],
          [:set, [
            [:and, [
              [:val, [:predicate, [:key?, [:books]]]],
              [
                :each, [
                  :set, [
                    [
                      :and, [
                        [:val, [:predicate, [:key?, [:published]]]],
                        [:key, [:published, [:predicate, [:bool?, []]]]]
                      ]
                    ]
                  ]
                ]
              ]
            ]]
          ]]
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
          [:val, [:predicate, [:key?, [:ids]]]],
          [:and, [
            [:key, [:ids, [:predicate, [:array?, []]]]],
            [:each, [:val, [:predicate, [:int?, []]]]]
          ]]
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
          [:val, [:predicate, [:key?, [:address]]]],
          [
            :and, [
              [:key, [:address, [:predicate, [:hash?, []]]]],
              [
                :set, [
                  [
                    :and, [
                      [:val, [:predicate, [:key?, [:street]]]],
                      [:key, [:street, [:predicate, [:filled?, []]]]]
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
