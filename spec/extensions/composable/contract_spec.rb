# frozen_string_literal: true

require 'dry/validation/extensions/composable'

RSpec.describe Dry::Validation::Contract do
  context 'with composable extension' do
    before { Dry::Validation.load_extensions(:composable) }

    subject(:contract) { contract_class.new }

    before do
      class Test::EmailContract < Dry::Validation::Contract
        params { required(:email).value(:string, format?: /@/) }
      end

      class Test::NameContract < Dry::Validation::Contract
        params { required(:name).filled(:string) }
      end
    end

    describe 'composed of two contracts' do
      let(:contract_class) do
        class Test::ComposedContract < Dry::Validation::Contract
          contract Test::EmailContract
          contract Test::NameContract
        end

        Test::ComposedContract
      end

      it 'has a composition for the two contracts' do
        expected = Dry::Validation::Composition.new
          .add_step(Test::EmailContract, nil)
          .add_step(Test::NameContract, nil)

        expect(contract_class.composition).to eq(expected)
      end

      it 'has a nice string representation' do
        composition_str = contract.composition.inspect
        expect(contract.inspect)
          .to eql("#<Test::ComposedContract composition=#{composition_str}>")
      end

      describe '#call(input)' do
        subject(:result) { contract.call(input) }

        let(:input) { { email: 'foo', name: 'jim', other: 'foo' } }

        it 'returns a result' do
          expect(subject).to be_failure
        end

        it 'has appropriate values' do
          expect(result.to_h).to eq(email: 'foo', name: 'jim')
        end

        it 'has appropriate errors' do
          expect(result.errors.to_h).to eq(email: ['is in invalid format'])
        end
      end
    end

    describe 'own schema/rules and composed of contract' do
      let(:contract_class) do
        class Test::ComposedContract < Dry::Validation::Contract
          contract Test::EmailContract
          contract Test::NameContract

          params do
            required(:phone).value(:string, format?: /\d+/)
          end

          rule(:phone) do
            emergency = /^000|999|911|01189998819991197253$/
            key.failure('is emergency services') if value =~ emergency
          end
        end

        Test::ComposedContract
      end

      describe '#call(input)' do
        subject(:result) { contract.call(input) }

        let(:input) do
          { email: 'moss#reynholm.com',
            name: 'Moss',
            phone: '01189998819991197253' }
        end

        it 'returns a result' do
          expect(subject).to be_failure
        end

        it 'has appropriate values' do
          expect(result.to_h).to eq(email: 'moss#reynholm.com',
                                    name: 'Moss',
                                    phone: '01189998819991197253')
        end

        it 'has appropriate errors' do
          expect(result.errors.to_h).to eq(email: ['is in invalid format'],
                                           phone: ['is emergency services'])
        end
      end
    end

    describe 'composed of multiple (composed) contracts at different paths' do
      before do
        class Test::PersonContract < Dry::Validation::Contract
          contract Test::EmailContract
          contract Test::NameContract
        end
      end

      let(:contract_class) do
        class Test::ComposedContract < Dry::Validation::Contract
          contract Test::PersonContract

          path :emergency do
            contract Test::PersonContract

            path :backup do
              contract Test::PersonContract
            end
          end
        end

        Test::ComposedContract
      end

      describe '#call(input)' do
        subject(:result) { contract.call(input) }

        let(:input) do
          { email: 'foo',
            name: '',
            shmemergency: { noise: 'XXXXXX' },
            emergency: { name: 'smudger',
                         whoops: 'why is this here?',
                         backup: { email: 'ok@email.com',
                                   name: '' } } }
        end

        it 'returns a result' do
          expect(subject).to be_failure
        end

        it 'has appropriate values at the specified paths' do
          expect(result.to_h).to eq(email: 'foo',
                                    name: '',
                                    emergency: { name: 'smudger',
                                                 backup: { email: 'ok@email.com',
                                                           name: '' } })
        end

        it 'has errors from all contracts at the specified paths' do
          expect(result.errors.to_h)
            .to eq(email: ['is in invalid format'],
                   name: ['must be filled'],
                   emergency: { email: ['is missing'],
                                backup: { name: ['must be filled'] } })
        end
      end
    end
  end
end
