require 'dry/validation/messages'
require 'dry/validation/error_compiler'

RSpec.describe Dry::Validation::ErrorCompiler do
  subject(:error_compiler) { ErrorCompiler.new(messages) }

  let(:messages) do
    Messages.default.merge(
      en: {
        errors: {
          key?: '+%{name}+ key is missing in the hash',
          rules: {
            address: {
              filled?: 'Please provide your address'
            }
          }
        }
      },
      pl: {
        rules: {
          email: 'adres email'
        },
        errors: {
          email?: 'nie jest poprawny'
        }
      }
    )
  end

  describe '#call with flat inputs' do
    let(:ast) do
      [
        [:error, [:name, [:input, [:name, [:result, [nil, [:val, [:predicate, [:key?, [:name]]]]]]]]]],
        [:error, [:age, [:input, [:age, [:result, [18, [:val, [:predicate, [:gt?, [18]]]]]]]]]],
        [:error, [:email, [:input, [:email, [:result, ["", [:val, [:predicate, [:filled?, []]]]]]]]]],
        [:error, [:address, [:input, [:address, [:result, ["", [:val, [:predicate, [:filled?, []]]]]]]]]]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql(
        name: ["+name+ key is missing in the hash"],
        age: ["must be greater than 18"],
        email: ["must be filled"],
        address: ["Please provide your address"]
      )
    end
  end

  describe '#call with check errors' do
    let(:ast) do
      [[:error, [:newsletter, [
          :input, [[:settings, :newsletter], [
            :result, [
              [true, true],
              [
                :check, [
                  :newsletter,
                  [:implication, [
                    [:key, [[:settings, :offers], [:predicate, [:true?, []]]]],
                    [:key, [[:settings, :newsletter], [:predicate, [:false?, []]]]]]
                  ]
                ]
              ]
            ]
          ]
        ]]]
      ]]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql(
        settings: { newsletter: ['must be false'] }
      )
    end
  end

  describe '#call with arr inputs' do
    let(:ast) do
      [[:error, [:payments,
        [:input, [
          :payments, [:result, [
              [{ method: "cc", amount: 1.23 }, { amount: 4.56 }], [:each, [
                [:el, [
                  1, [
                    :result, [{ amount: 4.56 }, [:val, [:predicate, [:key?, [:method]]]]]
                  ]
                ]]
              ]]]
          ]]]
      ]]]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql(
        payments: { 1 => { method: ['+method+ key is missing in the hash'] } }
      )
    end
  end

  describe '#visit with an :input node' do
    context 'full message' do
      it 'returns full message including rule name' do
        msg = error_compiler.with(full: true).visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:int?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['num must be an integer'])
      end
    end

    context 'rule name translations' do
      it 'translates rule name and its message' do
        msg = error_compiler.with(locale: :pl, full: true).visit(
          [:input, [:email, [
            :result, ['oops', [:val, [:predicate, [:email?, []]]]]]
          ]]
        )

        expect(msg).to eql(email: ['adres email nie jest poprawny'])
      end
    end

    describe ':empty?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:tags, [:result, [nil, [:val, [:predicate, [:empty?, []]]]]]]]
        )

        expect(msg).to eql(tags: ['must be empty'])
      end
    end

    describe ':exclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:exclusion?, [[1, 2, 3]]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must not be one of: 1, 2, 3'])
      end
    end

    describe ':excluded_from?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:excluded_from?, [[1, 2, 3]]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must not be one of: 1, 2, 3'])
      end
    end

    describe ':inclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:inclusion?, [[1, 2, 3]]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be one of: 1, 2, 3'])
      end
    end

    describe ':included_in?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:included_in?, [[1, 2, 3]]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be one of: 1, 2, 3'])
      end
    end

    describe ':gt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:gt?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be greater than 3'])
      end
    end

    describe ':gteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:gteq?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be greater than or equal to 3'])
      end
    end

    describe ':lt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:lt?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be less than 3'])
      end
    end

    describe ':lteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [2, [:val, [:predicate, [:lteq?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be less than or equal to 3'])
      end
    end

    describe ':hash?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:address, [
            :result, ['', [:val, [:predicate, [:hash?, []]]]]]
          ]]
        )

        expect(msg).to eql(address: ['must be a hash'])
      end
    end

    describe ':array?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:phone_numbers, [
            :result, ['', [:val, [:predicate, [:array?, []]]]]]
          ]]
        )

        expect(msg).to eql(phone_numbers: ['must be an array'])
      end
    end

    describe ':int?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:int?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be an integer'])
      end
    end

    describe ':float?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:float?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a float'])
      end
    end

    describe ':decimal?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:decimal?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a decimal'])
      end
    end

    describe ':date?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:date?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a date'])
      end
    end

    describe ':date_time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:date_time?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a date time'])
      end
    end

    describe ':time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['2', [:val, [:predicate, [:time?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a time'])
      end
    end

    describe ':max_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['abcd', [:val, [:predicate, [:max_size?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['size cannot be greater than 3'])
      end
    end

    describe ':min_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['ab', [:val, [:predicate, [:min_size?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['size cannot be less than 3'])
      end
    end

    describe ':none?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [nil, [:val, [:predicate, [:none?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['cannot be defined'])
      end
    end

    describe ':size?' do
      it 'returns valid message when val is array and arg is int' do
        msg = error_compiler.visit(
          [:input, [:numbers, [
            :result, [[1], [:val, [:predicate, [:size?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(numbers: ['size must be 3'])
      end

      it 'returns valid message when val is array and arg is range' do
        msg = error_compiler.visit(
          [:input, [:numbers, [
            :result, [[1], [:val, [:predicate, [:size?, [3..4]]]]]]
          ]]
        )

        expect(msg).to eql(numbers: ['size must be within 3 - 4'])
      end

      it 'returns valid message when arg is int' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['ab', [:val, [:predicate, [:size?, [3]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['length must be 3'])
      end

      it 'returns valid message when arg is range' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, ['ab', [:val, [:predicate, [:size?, [3..4]]]]]]
          ]]
        )

        expect(msg).to eql(num: ['length must be within 3 - 4'])
      end
    end

    describe ':str?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [3, [:val, [:predicate, [:str?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be a string'])
      end
    end

    describe ':bool?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [
            :result, [3, [:val, [:predicate, [:bool?, []]]]]]
          ]]
        )

        expect(msg).to eql(num: ['must be boolean'])
      end
    end

    describe ':format?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [
            :result, ['Bar', [:val, [:predicate, [:format?, [/^F/]]]]]]
          ]]
        )

        expect(msg).to eql(str: ['is in invalid format'])
      end
    end

    describe ':eql?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [
            :result, ['Foo', [:val, [:predicate, [:eql?, ['Bar']]]]]]
          ]]
        )

        expect(msg).to eql(str: ['must be equal to Bar'])
      end
    end

    describe ':type??' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:age, [
            :result, ['1', [:val, [:predicate, [:type?, [Integer]]]]]]
          ]]
        )

        expect(msg).to eql(age: ['must be Integer'])
      end
    end
  end
end
