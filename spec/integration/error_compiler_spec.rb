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

  describe '#call' do
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

  describe '#visit_predicate' do
    describe ':empty?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:empty?, []], [], :tags)

        expect(msg).to eql('tags cannot be empty')
      end
    end

    describe ':exclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:exclusion?, [[1, 2, 3]]], 2, :num)

        expect(msg).to eql('num must not be one of: 1, 2, 3')
      end
    end

    describe ':inclusion?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:inclusion?, [[1, 2, 3]]], 2, :num)

        expect(msg).to eql('num must be one of: 1, 2, 3')
      end
    end

    describe ':gt?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:gt?, [3]], 2, :num)

        expect(msg).to eql('num must be greater than 3')
      end
    end

    describe ':gteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:gteq?, [3]], 2, :num)

        expect(msg).to eql('num must be greater than or equal to 3')
      end
    end

    describe ':lt?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:lt?, [3]], 2, :num)

        expect(msg).to eql('num must be less than 3 (2 was given)')
      end
    end

    describe ':lteq?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:lteq?, [3]], 2, :num)

        expect(msg).to eql('num must be less than or equal to 3')
      end
    end

    describe ':hash?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:hash?, []], '', :address)

        expect(msg).to eql('address must be a hash')
      end
    end

    describe ':array?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:array?, []], '', :phone_numbers)

        expect(msg).to eql('phone_numbers must be an array')
      end
    end

    describe ':int?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:int?, []], '2', :num)

        expect(msg).to eql('num must be an integer')
      end
    end

    describe ':float?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:float?, []], '2', :num)

        expect(msg).to eql('num must be a float')
      end
    end

    describe ':decimal?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:decimal?, []], '2', :num)

        expect(msg).to eql('num must be a decimal')
      end
    end

    describe ':date?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:date?, []], '2', :num)

        expect(msg).to eql('num must be a date')
      end
    end

    describe ':date_time?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:date_time?, []], '2', :num)

        expect(msg).to eql('num must be a date time')
      end
    end

    describe ':time?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:time?, []], '2', :num)

        expect(msg).to eql('num must be a time')
      end
    end

    describe ':max_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:max_size?, [3]], 'abcd', :num)

        expect(msg).to eql('num size cannot be greater than 3')
      end
    end

    describe ':min_size?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:min_size?, [3]], 'ab', :num)

        expect(msg).to eql('num size cannot be less than 3')
      end
    end

    describe ':none?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:none?, []], nil, :num)

        expect(msg).to eql('num cannot be defined')
      end
    end

    describe ':size?' do
      it 'returns valid message when val is array and arg is int' do
        msg = error_compiler.visit_predicate([:size?, [3]], [1], :numbers)

        expect(msg).to eql('numbers size must be 3')
      end

      it 'returns valid message when val is array and arg is range' do
        msg = error_compiler.visit_predicate([:size?, [3..4]], [1], :numbers)

        expect(msg).to eql('numbers size must be within 3 - 4')
      end

      it 'returns valid message when arg is int' do
        msg = error_compiler.visit_predicate([:size?, [3]], 'ab', :num)

        expect(msg).to eql('num length must be 3')
      end

      it 'returns valid message when arg is range' do
        msg = error_compiler.visit_predicate([:size?, [3..4]], 'ab', :num)

        expect(msg).to eql('num length must be within 3 - 4')
      end
    end

    describe ':str?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:str?, []], 3, :num)

        expect(msg).to eql('num must be a string')
      end
    end

    describe ':bool?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:bool?, []], 3, :num)

        expect(msg).to eql('num must be boolean')
      end
    end

    describe ':format?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:format?, [/^F/]], 'Bar', :str)

        expect(msg).to eql('str is in invalid format')
      end
    end

    describe ':eql?' do
      it 'returns valid message' do
        msg = error_compiler.visit_predicate([:eql?, ['Bar']], 'Foo', :str)

        expect(msg).to eql('str must be equal to Bar')
      end
    end
  end
end
