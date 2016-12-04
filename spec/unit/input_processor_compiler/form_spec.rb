RSpec.describe Dry::Validation::InputProcessorCompiler::Form, '#call' do
  subject(:compiler) { Dry::Validation::InputProcessorCompiler::Form.new }

  include_context 'predicate helper'

  let(:rule_ast) do
    [
      [
        :and, [
          p(:key?, :email),
          [
            :and, [
              [:key, [:email, p(:str?)]],
              [:key, [:email, p(:filled?)]]
            ]
          ]
        ]
      ],
      [
        :and, [
          p(:key?, :age),
          [
            :or, [
              [:key, [:age, p(:none?)]],
              [
                :and, [
                  [:key, [:age, p(:int?)]],
                  [:key, [:age, p(:filled?)]]
                ]
              ]
            ]
          ]
        ]
      ],
      [
        :and, [
          p(:key?, :address),
          [:key, [:address, p(:str?)]]
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

  it 'supports arbitrary types via type?(const) => "form.const"' do
    rule_ast = [
      [
        :and,
        [
          [:val, p(:key?, :age)],
          [:key, [:age, p(:type?, Integer)]]
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['age' => '21']).to eql(age: 21)
  end

  it 'supports arbitrary types via type?(conts)' do
    rule_ast = [
      [
        :and,
        [
          [:val, p(:key?, :admin)],
          [:key, [:admin, p(:type?, 'Form::Bool')]]
        ]
      ]
    ]

    input_type = compiler.(rule_ast)

    expect(input_type['admin' => '0']).to eql(admin: false)
  end

  it 'supports int? => "form.int"' do
    rule_ast = [
      [
        :and,
        [
          [:val, p(:key?, :age)],
          [:key, [:age, p(:int?)]],
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
          [:val, p(:key?, :age)],
          [
            :or, [
              [:key, [:age, p(:none?)]],
              [:key, [:age, p(:int?)]],
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
          [:val, p(:key?, :lat)],
          [:key, [:lat, p(:float?)]],
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
          [:val, p(:key?, :lat)],
          [:key, [:lat, p(:decimal?, [])]],
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
          [:val, p(:key?, :bday)],
          [:key, [:bday, p(:date?, [])]],
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
          [:val, p(:key?, :bday)],
          [:key, [:bday, p(:date_time?, [])]],
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
          [:val, p(:key?, :bday)],
          [:key, [:bday, p(:time?, [])]],
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
          [:val, p(:key?, :bday)],
          [:key, [:bday, p(:time?, [])]],
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
          [:val, p(:key?, :admin)],
          [:key, [:admin, p(:bool?, [])]],
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
          [:val, p(:key?, :author)],
          [:set, [
            [:and, [
              [:val, p(:key?, :books)],
              [
                :each, [
                  :set, [
                    [
                      :and, [
                        [:val, p(:key?, :published)],
                        [:key, [:published, p(:bool?, [])]]
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
          [:val, p(:key?, :ids)],
          [:and, [
            [:key, [:ids, p(:array?, [])]],
            [:each, [:val, p(:int?, [])]]
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
          [:val, p(:key?, :address)],
          [
            :and, [
              [:key, [:address, p(:hash?, [])]],
              [
                :set, [
                  [
                    :and, [
                      [:val, p(:key?, :street)],
                      [:key, [:street, p(:filled?, [])]]
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
