RSpec.describe Dry::Validation::Schema::Form, 'explicit types' do
  context 'single type spec without rules' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:age, :int)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end

  context 'single type spec with rules' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:age, :int).value(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'single type spec with an array' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:nums, [:int])
      end
    end

    it 'uses form coercion' do
      expect(schema.(nums: %w(1 2 3)).to_h).to eql(nums: [1, 2, 3])
    end
  end

  context 'sum type spec without rules' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:age, [:nil, :int])
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '19').to_h).to eql(age: 19)
      expect(schema.('age' => '').to_h).to eql(age: nil)
    end
  end

  context 'sum type spec with rules' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:age, [:nil, :int]).maybe(:int?, gt?: 18)
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(age: nil).messages).to be_empty
      expect(schema.(age: 19).messages).to be_empty
      expect(schema.(age: 18).messages).to eql(age: ['must be greater than 18'])
    end
  end

  context 'using a type object' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }
        required(:age, Types::Form::Nil | Types::Form::Int)
      end
    end

    it 'uses form coercion' do
      expect(schema.('age' => '').to_h).to eql(age: nil)
      expect(schema.('age' => '19').to_h).to eql(age: 19)
    end
  end

  context 'nested schema' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }

        required(:user).schema do
          required(:email, :string)
          required(:age, :int)

          required(:address).schema do
            required(:street, :string)
            required(:city, :string)
            required(:zipcode, :string)

            required(:location).schema do
              required(:lat, :float)
              required(:lng, :float)
            end
          end
        end
      end
    end

    it 'uses form coercion for nested input' do
      input = {
        'user' => {
          'email' => 'jane@doe.org',
          'age' => '21',
          'address' => {
            'street' => 'Street 1',
            'city' => 'NYC',
            'zipcode' => '1234',
            'location' => { 'lat' => '1.23', 'lng' => '4.56' }
          }
        }
      }

      expect(schema.(input).to_h).to eql(
        user:  {
          email: 'jane@doe.org',
          age: 21,
          address: {
            street: 'Street 1',
            city: 'NYC',
            zipcode:  '1234',
            location: { lat: 1.23, lng: 4.56 }
          }
        }
      )
    end
  end

  context 'nested schema with arrays' do
    subject(:schema) do
      Dry::Validation.Form do
        configure { config.type_specs = true }

        required(:song).schema do
          required(:title, :string)

          required(:tags).each do
            schema do
              required(:name, :string)
            end
          end
        end
      end
    end

    it 'fails to coerce gracefuly' do
      result = schema.(song: nil)

      expect(result.messages).to eql(song: ['must be a hash'])
      expect(result.to_h).to eql(song: nil)

      result = schema.(song: { tags: nil })

      expect(result.messages).to eql(song: { tags: ['must be an array'] })
      expect(result.to_h).to eql(song: { tags: nil })
    end

    it 'uses form coercion for nested input' do
      input = {
        'song' => {
          'title' => 'dry-rb is awesome lala',
          'tags' => [{ 'name' => 'red' }, { 'name' => 'blue' }]
        }
      }

      expect(schema.(input).to_h).to eql(
        song: {
          title: 'dry-rb is awesome lala',
          tags: [{ name: 'red' }, { name: 'blue' }]
        }
      )
    end
  end
end
