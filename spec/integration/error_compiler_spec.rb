require 'dry/validation/messages'
require 'dry/validation/error_compiler'

RSpec.describe Dry::Validation::ErrorCompiler do
  subject(:error_compiler) { ErrorCompiler.new(messages) }

  let(:messages) do
    Messages.default.merge(
      en: {
        errors: {
          key?: '+%{name}+ key is missing in the hash',
          attr?: 'Object does not respond to the +%{name}+ attr',
          rules: {
            address: {
              filled?: 'Please provide your address'
            }
          }
        }
      }
    )
  end

  describe '#call with flat inputs' do
    let(:ast) do
      [
        [:error, [:input, [:name, nil, [[:key, [:name, [:predicate, [:key?, []]]]]]]]],
        [:error, [:input, [:phone, nil, [[:attr, [:phone, [:predicate, [:attr?, []]]]]]]]],
        [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
        [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]],
        [:error, [:input, [:address, "", [[:val, [:address, [:predicate, [:filled?, []]]]]]]]]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql(
        name: [["+name+ key is missing in the hash"], nil],
        phone: [["Object does not respond to the +phone+ attr"], nil],
        age: [["age must be greater than 18"], 18],
        email: [["email must be filled"], ''],
        address: [["Please provide your address"], '']
      )
    end
  end

  describe '#call with check errors' do
    let(:ast) do
      [
        [:error, [
          :input, [
            [:settings, :newsletter], [true, true], [
              [
                :check, [
                  [:settings, :newsletter],
                  [:implication, [
                    [:res, [[:settings, :offers], [:predicate, [:true?, []]]]],
                    [:res, [[:settings, :newsletter], [:predicate, [:false?, []]]]]]
                  ]
                ]
              ]
            ]
          ]
        ]]
      ]
    end

    it 'converts error ast into another format' do
      expect(error_compiler.(ast)).to eql(
        settings: { newsletter: [['newsletter must be false'], [true, true]] }
      )
    end
  end

  describe '#visit with an :input node' do
    describe ':empty?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:tags, nil, [[:val, [:tags, [:predicate, [:empty?, []]]]]]]]
        )

        expect(msg).to eql(tags: [['tags cannot be empty'], nil])
      end
    end

    describe ':exclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:exclusion?, [[1, 2, 3]]]]]]]]]
        )

        expect(msg).to eql(num: [['num must not be one of: 1, 2, 3'], 2])
      end
    end

    describe ':inclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:inclusion?, [[1, 2, 3]]]]]]]]]
        )

        expect(msg).to eql(num: [['num must be one of: 1, 2, 3'], 2])
      end
    end

    describe ':gt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:gt?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num must be greater than 3'], 2])
      end
    end

    describe ':gteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:gteq?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num must be greater than or equal to 3'], 2])
      end
    end

    describe ':lt?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:lt?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num must be less than 3 (2 was given)'], 2])
      end
    end

    describe ':lteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 2, [[:val, [:num, [:predicate, [:lteq?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num must be less than or equal to 3'], 2])
      end
    end

    describe ':hash?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:address, '', [[:val, [:address, [:predicate, [:hash?, []]]]]]]]
        )

        expect(msg).to eql(address: [['address must be a hash'], ''])
      end
    end

    describe ':array?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [
            :phone_numbers, '',
            [[:val, [:phone_numbers, [:predicate, [:array?, []]]]]]]
          ]
        )

        expect(msg).to eql(phone_numbers: [['phone_numbers must be an array'], ''])
      end
    end

    describe ':int?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:int?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be an integer'], '2'])
      end
    end

    describe ':float?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:float?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a float'], '2'])
      end
    end

    describe ':decimal?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:decimal?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a decimal'], '2'])
      end
    end

    describe ':date?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:date?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a date'], '2'])
      end
    end

    describe ':date_time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:date_time?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a date time'], '2'])
      end
    end

    describe ':time?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, '2', [[:val, [:num, [:predicate, [:time?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a time'], '2'])
      end
    end

    describe ':max_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 'abcd', [[:val, [:num, [:predicate, [:max_size?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num size cannot be greater than 3'], 'abcd'])
      end
    end

    describe ':min_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 'ab', [[:val, [:num, [:predicate, [:min_size?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num size cannot be less than 3'], 'ab'])
      end
    end

    describe ':none?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, nil, [[:val, [:num, [:predicate, [:none?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num cannot be defined'], nil])
      end
    end

    describe ':size?' do
      it 'returns valid message when val is array and arg is int' do
        msg = error_compiler.visit(
          [:input, [:numbers, [1], [[:val, [:numbers, [:predicate, [:size?, [3]]]]]]]]
        )

        expect(msg).to eql(numbers: [['numbers size must be 3'], [1]])
      end

      it 'returns valid message when val is array and arg is range' do
        msg = error_compiler.visit(
          [:input, [:numbers, [1], [[:val, [:numbers, [:predicate, [:size?, [3..4]]]]]]]]
        )

        expect(msg).to eql(numbers: [['numbers size must be within 3 - 4'], [1]])
      end

      it 'returns valid message when arg is int' do
        msg = error_compiler.visit(
          [:input, [:num, 'ab', [[:val, [:num, [:predicate, [:size?, [3]]]]]]]]
        )

        expect(msg).to eql(num: [['num length must be 3'], 'ab'])
      end

      it 'returns valid message when arg is range' do
        msg = error_compiler.visit(
          [:input, [:num, 'ab', [[:val, [:num, [:predicate, [:size?, [3..4]]]]]]]]
        )

        expect(msg).to eql(num: [['num length must be within 3 - 4'], 'ab'])
      end
    end

    describe ':str?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 3, [[:val, [:num, [:predicate, [:str?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be a string'], 3])
      end
    end

    describe ':bool?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:num, 3, [[:val, [:num, [:predicate, [:bool?, []]]]]]]]
        )

        expect(msg).to eql(num: [['num must be boolean'], 3])
      end
    end

    describe ':format?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, 'Bar', [[:val, [:str, [:predicate, [:format?, [/^F/]]]]]]]]
        )

        expect(msg).to eql(str: [['str is in invalid format'], 'Bar'])
      end
    end

    describe ':eql?' do
      it 'returns valid message' do
        msg = error_compiler.visit(
          [:input, [:str, 'Foo', [[:val, [:str, [:predicate, [:eql?, ['Bar']]]]]]]]
        )

        expect(msg).to eql(str: [['str must be equal to Bar'], 'Foo'])
      end
    end
  end
end
