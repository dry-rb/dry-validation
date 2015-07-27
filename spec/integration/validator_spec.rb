RSpec.describe 'Dry::Validator' do
  describe 'merging validators' do
    let(:first) do
      Dry::Validator.new(
        first_name: {
          presence: true,
          inclusion: %w(Jack Jill),
          length: 5..10
        },
        last_name: {
          presence: true,
          length: 5..15
        },
        permissions: {
          each: {
            type: {
              presence: true
            },
            granted: {
              inclusion: [true, false]
            }
          }
        }
      )
    end
    let(:second) do
      Dry::Validator.new(
        rules: {
          first_name: {
            inclusion: %w(Janet John),
            length: 5..15
          },
          permissions: {
            each: {
              type: {
                presence: true
              },
              granted: {
                inclusion: [true]
              }
            }
          }
        },
        processor: ::Dry::Validator::Processor.dup
      )
    end
    let!(:merged) { first.merge(second) }

    it 'deep merges rules' do
      expect(merged.rules).to eq(
        first_name: {
          presence: true,
          inclusion: %w(Janet John),
          length: 5..15
        },
        last_name: {
          presence: true,
          length: 5..15
        },
        permissions: {
          each: {
            type: {
              presence: true
            },
            granted: {
              inclusion: [true]
            }
          }
        }
      )
    end

    it 'overwrites the processor' do
      expect(merged.processor).to_not be(first.processor)
      expect(merged.processor).to be(second.processor)
    end
  end

  describe 'validate each' do
    subject! { validator.call(attributes) }

    context 'with rules hash' do
      let(:validator) do
        Dry::Validator.new(
          users: {
            each: {
              name: {
                presence: true
              }
            }
          }
        )
      end

      context 'when invalid' do
        let(:attributes) do
          { users: [{ name: 'Jack' }, { name: 'Jill' }, { name: '' }] }
        end

        it 'returns a hash with errors' do
          is_expected.to include(
            users: [
              {
                code: 'each',
                errors: [
                  {},
                  {},
                  {
                    name: [{ code: 'presence', value: '', options: true }]
                  }
                ],
                value: [
                  { name: 'Jack' },
                  { name: 'Jill' },
                  { name: '' }
                ],
                options: {
                  name: { presence: true }
                }
              }
            ]
          )
        end
      end

      context 'when valid' do
        let(:attributes) do
          { users: [{ name: 'Jack' }, { name: 'Jill' }, { name: 'Jo' }] }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with validator' do
      let(:user_validator) { Dry::Validator.new(name: { presence: true }) }
      let(:validator) { Dry::Validator.new(users: { each: user_validator }) }

      context 'when invalid' do
        let(:attributes) do
          { users: [{ name: 'Jack' }, { name: 'Jill' }, { name: '' }] }
        end

        it 'returns a hash with errors' do
          is_expected.to include(
            users: [
              {
                code: 'each',
                errors: [
                  {},
                  {},
                  {
                    name: [{ code: 'presence', value: '', options: true }]
                  }
                ],
                value: [
                  { name: 'Jack' },
                  { name: 'Jill' },
                  { name: '' }
                ],
                options: {
                  name: { presence: true }
                }
              }
            ]
          )
        end
      end

      context 'when valid' do
        let(:attributes) do
          { users: [{ name: 'Jack' }, { name: 'Jill' }, { name: 'Jo' }] }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'validate embedded' do
    subject! { validator.call(attributes) }

    context 'with rules hash' do
      let(:validator) do
        Dry::Validator.new(
          user: {
            embedded: {
              name: {
                presence: true
              }
            }
          }
        )
      end

      context 'when invalid' do
        let(:attributes) do
          { user: { name: '' } }
        end

        it 'returns a hash with errors' do
          is_expected.to include(
            user: [
              {
                code: 'embedded',
                errors: {
                  name: [{ code: 'presence', value: '', options: true }]
                },
                value: { name: '' },
                options: { name: { presence: true } }
              }
            ]
          )
        end
      end

      context 'when valid' do
        let(:attributes) do
          { user: { name: 'Jack' } }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with validator' do
      let(:user_validator) { Dry::Validator.new(name: { presence: true }) }
      let(:validator) { Dry::Validator.new(user: { embedded: user_validator }) }

      context 'when invalid' do
        let(:attributes) do
          { user: { name: '' } }
        end

        it 'returns a hash with errors' do
          is_expected.to include(
            user: [
              {
                code: 'embedded',
                errors: {
                  name: [{ code: 'presence', value: '', options: true }]
                },
                value: { name: '' },
                options: { name: { presence: true } }
              }
            ]
          )
        end
      end

      context 'when valid' do
        let(:attributes) do
          { user: { name: 'Jack' } }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'validate exclusion' do
    subject! { validator.call(attributes) }

    let(:validator) do
      Dry::Validator.new(
        name: { exclusion: %w(Jack Jill) }
      )
    end

    context 'when attribute included' do
      let(:attributes) do
        { name: 'Jack' }
      end

      it 'returns a hash with errors' do
        is_expected.to include(name: [
          { code: 'exclusion', value: 'Jack', options: %w(Jack Jill) }
        ])
      end
    end

    context 'when attribute not included' do
      let(:attributes) do
        { name: 'Jo' }
      end

      it 'returns an empty hash' do
        is_expected.to be_empty
      end
    end
  end

  describe 'validate inclusion' do
    subject! { validator.call(attributes) }

    let(:validator) do
      Dry::Validator.new(
        name: { inclusion: %w(Jack Jill) }
      )
    end

    context 'when attribute not included' do
      let(:attributes) do
        { name: 'Jo' }
      end

      it 'returns a hash with errors' do
        is_expected.to include(name: [
          { code: 'inclusion', value: 'Jo', options: %w(Jack Jill) }
        ])
      end
    end

    context 'when attribute included' do
      let(:attributes) do
        { name: 'Jack' }
      end

      it 'returns an empty hash' do
        is_expected.to be_empty
      end
    end
  end

  describe 'validate length' do
    subject! { validator.call(attributes) }

    context 'with range option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: 2..5 }
        )
      end

      context 'when attribute not in range' do
        let(:attributes) do
          { name: '' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', value: '', options: { min: 2, max: 5 } }
          ])
        end
      end

      context 'when attribute in range' do
        let(:attributes) do
          { name: 'Jill' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with max option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: { max: 5 } }
        )
      end

      context 'when attribute too long' do
        let(:attributes) do
          { name: 'Jack Smith' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', value: 'Jack Smith', options: { max: 5 } }
          ])
        end
      end

      context 'when attribute short enough' do
        let(:attributes) do
          { name: 'Jill' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with min option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: { min: 5 } }
        )
      end

      context 'when attribute too short' do
        let(:attributes) do
          { name: 'Jack' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', value: 'Jack', options: { min: 5 } }
          ])
        end
      end

      context 'when attribute length in range' do
        let(:attributes) do
          { name: 'Jillian' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'validate presence' do
    subject! { validator.call(attributes) }

    context 'with option true' do
      let(:validator) do
        Dry::Validator.new(
          name: { presence: true }
        )
      end

      context 'when attribute not present' do
        let(:attributes) do
          { name: '' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'presence', value: '', options: true }
          ])
        end
      end

      context 'when attribute present' do
        let(:attributes) do
          { name: 'Jack' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end
end
