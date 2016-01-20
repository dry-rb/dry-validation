RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  before do
    def schema.messages
      Messages.default.merge(
        en: { errors: { password_confirmation: 'does not match' } }
      )
    end
  end

  describe 'defining schema with rule groups' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        confirmation(:password)
      end
    end

    describe '#call' do
      it 'returns empty errors when password matches confirmation' do
        expect(validation.(password: 'foo', password_confirmation: 'foo')).to be_empty
      end

      it 'returns error for a failed group rule' do
        expect(validation.(password: 'foo', password_confirmation: 'bar')).to match_array([
          [:error, [
            :input, [
              :password_confirmation,
              ["foo", "bar"],
              [[:group, [:password_confirmation, [:predicate, [:eql?, []]]]]]]]
          ]
        ])
      end

      it 'returns messages for a failed group rule' do
        expect(validation.(password: 'foo', password_confirmation: 'bar').messages).to eql(
          password_confirmation: [['does not match'], ['foo', 'bar']]
        )
      end

      it 'returns errors for the dependent predicates, not the group rule, when any of the dependent predicates fail' do
        expect(validation.(password: '', password_confirmation: '')).to match_array([
          [:error, [:input, [:password, "", [[:val, [:password, [:predicate, [:filled?, []]]]]]]]],
          [:error, [:input, [:password_confirmation, "", [[:val, [:password_confirmation, [:predicate, [:filled?, []]]]]]]]]
        ])
      end
    end

    describe 'confirmation' do
      shared_examples_for 'confirmation behavior' do
        it 'applies custom rules' do
          expect(validation.(password: 'abcd').messages).to include(
            password: [['password size cannot be less than 6'], 'abcd']
          )
        end

        it 'applies confirmation equality predicate' do
          expect(validation.(password: 'abcdef', password_confirmation: 'abcd').messages).to include(
            password_confirmation: [['does not match'], ['abcdef', 'abcd']]
          )
        end

        it 'skips default predicate' do
          expect(validation.(password: '', password_confirmation: '').messages).to include(
            password: [['password size cannot be less than 6'], ''],
            password_confirmation: [['password_confirmation must be filled'], '']
          )
        end
      end

      describe 'custom predicates' do
        let(:schema) do
          Class.new(Dry::Validation::Schema) do
            key(:password) { |value| value.min_size?(6) }

            confirmation(:password)
          end
        end

        it_behaves_like 'confirmation behavior'
      end

      describe 'custom predicates using shortcut options' do
        let(:schema) do
          Class.new(Dry::Validation::Schema) do
            confirmation(:password, min_size: 6)
          end
        end

        it_behaves_like 'confirmation behavior'
      end
    end
  end
end
