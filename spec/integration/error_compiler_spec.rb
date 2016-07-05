require 'dry/validation/messages'
require 'dry/validation/error_compiler'

RSpec.describe Dry::Validation::ErrorCompiler do
  subject(:error_compiler) { ErrorCompiler.new(messages) }

  include_context 'predicate helper'

  let(:messages) do
    Messages.default.merge(
      en: {
        errors: {
          key?: {
            arg: {
              default: '+%{name}+ key is missing in the hash',
            },
            value: {
              gender: 'Please provide your gender'
            }
          },
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
        [:error, [:name, [:input, [:name, [:result, [nil, [:val, p(:key?, :name)]]]]]]],
        [:error, [:gender, [:input, [:gender, [:result, [nil, [:val, p(:key?, :gender)]]]]]]],
        [:error, [:age, [:input, [:age, [:result, [18, [:val, p(:gt?, 18)]]]]]]],
        [:error, [:email, [:input, [:email, [:result, ["", [:val, p(:filled?)]]]]]]],
        [:error, [:address, [:input, [:address, [:result, ["", [:val, p(:filled?)]]]]]]]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast).to_h).to eql(
        name: ["+name+ key is missing in the hash"],
        gender: ["Please provide your gender"],
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
                    [:key, [[:settings, :offers], p(:true?)]],
                    [:key, [[:settings, :newsletter], p(:false?)]]]
                  ]
                ]
              ]
            ]
          ]
        ]]]
      ]]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast).to_h).to eql(
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
                    :result, [{ amount: 4.56 }, [:val, p(:key?, :method)]]
                  ]
                ]]
              ]]]
          ]]]
      ]]]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast).to_h).to eql(
        payments: { 1 => { method: ['+method+ key is missing in the hash'] } }
      )
    end
  end

  describe '#visit with an :input node' do
    context 'full message' do
      it 'returns full message including rule name' do
        msg = error_compiler.with(full: true).visit(
          [:input, [:num, [:result, ['2', [:val, p(:int?)]]]]]
        )

        expect(msg).to eql('num must be an integer')
      end
    end

    context 'rule name translations' do
      it 'translates rule name and its message' do
        msg = error_compiler.with(locale: :pl, full: true).visit(
          [:input, [:email, [:result, ['oops', [:val, p(:email?)]]]]]
        )

        expect(msg).to eql('adres email nie jest poprawny')
      end
    end

    describe ':empty?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:tags, [:result, [nil, [:val, p(:empty?)]]]]]
        )

        expect(msg).to eql('must be empty')
      end
    end

    describe ':excluded_from?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:excluded_from?, [1, 2, 3])]]]]]
        )

        expect(msg).to eql('must not be one of: 1, 2, 3')
      end
    end

    describe ':excludes?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:array, [:result, [[1, 2, 3], [:val, p(:excludes?, 2)]]]]]
        )

        expect(msg).to eql('must not include 2')
      end
    end

    describe ':included_in?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:included_in?, [1, 2, 3])]]]]]
        )

        expect(msg).to eql('must be one of: 1, 2, 3')
      end
    end

    describe ':includes?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [[1, 2, 3], [:val, p(:includes?, 2)]]]]]
        )

        expect(msg).to eql('must include 2')
      end
    end

    describe ':gt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:gt?, 3)]]]]]
        )

        expect(msg).to eql('must be greater than 3')
      end
    end

    describe ':gteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:gteq?, 3)]]]]]
        )

        expect(msg).to eql('must be greater than or equal to 3')
      end
    end

    describe ':lt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:lt?, 3)]]]]]
        )

        expect(msg).to eql('must be less than 3')
      end
    end

    describe ':lteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [2, [:val, p(:lteq?, 3)]]]]]
        )

        expect(msg).to eql('must be less than or equal to 3')
      end
    end

    describe ':hash?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:address, [:result, ['', [:val, p(:hash?, [])]]]]]
        )

        expect(msg).to eql('must be a hash')
      end
    end

    describe ':array?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:phone_numbers, [:result, ['', [:val, p(:array?)]]]]]
        )

        expect(msg).to eql('must be an array')
      end
    end

    describe ':int?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:int?)]]]]]
        )

        expect(msg).to eql('must be an integer')
      end
    end

    describe ':float?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:float?)]]]]]
        )

        expect(msg).to eql('must be a float')
      end
    end

    describe ':decimal?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:decimal?)]]]]]
        )

        expect(msg).to eql('must be a decimal')
      end
    end

    describe ':date?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:date?)]]]]]
        )

        expect(msg).to eql('must be a date')
      end
    end

    describe ':date_time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:date_time?)]]]]]
        )

        expect(msg).to eql('must be a date time')
      end
    end

    describe ':time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['2', [:val, p(:time?)]]]]]
        )

        expect(msg).to eql('must be a time')
      end
    end

    describe ':max_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['abcd', [:val, p(:max_size?, 3)]]]]]
        )

        expect(msg).to eql('size cannot be greater than 3')
      end
    end

    describe ':min_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['ab', [:val, p(:min_size?, 3)]]]]]
        )

        expect(msg).to eql('size cannot be less than 3')
      end
    end

    describe ':none?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [nil, [:val, p(:none?)]]]]]
        )

        expect(msg).to eql('cannot be defined')
      end
    end

    describe ':size?' do
      it 'returns valid message when val is array and arg is int' do
        msg = error_compiler.visit(
          [:input, [:numbers, [:result, [[1], [:val, p(:size?, 3)]]]]]
        )

        expect(msg).to eql('size must be 3')
      end

      it 'returns valid message when val is array and arg is range' do
        msg = error_compiler.visit(
          [:input, [:numbers, [:result, [[1], [:val, p(:size?, 3..4)]]]]]
        )

        expect(msg).to eql('size must be within 3 - 4')
      end

      it 'returns valid message when arg is int' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['ab', [:val, p(:size?, 3)]]]]]
        )

        expect(msg).to eql('length must be 3')
      end

      it 'returns valid message when arg is range' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, ['ab', [:val, p(:size?, 3..4)]]]]]
        )

        expect(msg).to eql('length must be within 3 - 4')
      end
    end

    describe ':str?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [3, [:val, p(:str?)]]]]]
        )

        expect(msg).to eql('must be a string')
      end
    end

    describe ':bool?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, [:result, [3, [:val, p(:bool?)]]]]]
        )

        expect(msg).to eql('must be boolean')
      end
    end

    describe ':format?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, ['Bar', [:val, p(:format?, /^F/)]]]]]
        )

        expect(msg).to eql('is in invalid format')
      end
    end

    describe ':number?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, ["not a number", [:val, p(:number?)]]]]]
        )

        expect(msg).to eql('must be a number')
      end
    end

    describe ':odd?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, [1, [:val, p(:odd?)]]]]]
        )

        expect(msg).to eql('must be odd')
      end
    end

    describe ':even?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, [2, [:val, p(:even?)]]]]]
        )

        expect(msg).to eql('must be even')
      end
    end

    describe ':eql?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, ['Foo', [:val, p(:eql?, 'Bar')]]]]]
        )

        expect(msg).to eql('must be equal to Bar')
      end
    end

    describe ':not_eql?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, [:result, ['Foo', [:val, p(:not_eql?, 'Foo')]]]]]
        )

        expect(msg).to eql('must not be equal to Foo')
      end
    end

    describe ':type?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:age, [:result, ['1', [:val, p(:type?, Integer)]]]]]
        )

        expect(msg).to eql('must be Integer')
      end
    end
  end
end
