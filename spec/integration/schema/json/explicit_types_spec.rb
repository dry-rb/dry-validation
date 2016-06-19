RSpec.describe Dry::Validation::Schema::JSON, 'explicit types' do
  context 'single type spec without rules' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }
        required(:bdate, :date)
      end
    end

    it 'uses json coercion' do
      expect(schema.('bdate' => '2010-09-08').to_h).to eql(bdate: Date.new(2010, 9, 8))
    end
  end

  context 'single type spec with rules' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }
        required(:bdate, :date).value(:date?, gt?: Date.new(2009))
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(bdate: "2010-09-07").messages).to be_empty
      expect(schema.(bdate: "2008-01-01").messages).to eql(bdate: ['must be greater than 2009-01-01'])
    end
  end

  context 'sum type spec without rules' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }
        required(:bdate, [:nil, :date])
      end
    end

    it 'uses form coercion' do
      expect(schema.('bdate' => '2010-09-08').to_h).to eql(bdate: Date.new(2010, 9, 8))
      expect(schema.('bdate' => '').to_h).to eql(bdate: nil)
    end
  end

  context 'sum type spec with rules' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }
        required(:bdate, [:nil, :date]).maybe(:date?, gt?: Date.new(2008))
      end
    end

    it 'applies rules to coerced value' do
      expect(schema.(bdate: nil).messages).to be_empty
      expect(schema.(bdate: "2010-09-07").messages).to be_empty
      expect(schema.(bdate: "2008-01-01").messages).to eql(bdate: ['must be greater than 2008-01-01'])
    end
  end

  context 'using a type object' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }
        required(:bdate, Types::Json::Nil | Types::Json::Date)
      end
    end

    it 'uses form coercion' do
      expect(schema.('bdate' => '').to_h).to eql(bdate: nil)
      expect(schema.('bdate' => '2010-09-08').to_h).to eql(bdate: Date.new(2010, 9, 8))
    end
  end

  context 'nested schema' do
    subject(:schema) do
      Dry::Validation.JSON do
        configure { config.type_specs = true }

        required(:user).schema do
          required(:email, :string)
          required(:bdate, :date)

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
          'bdate' => '2010-09-08',
          'address' => {
            'street' => 'Street 1',
            'city' => 'NYC',
            'zipcode' => '1234',
            'location' => { 'lat' => 1.23, 'lng' => 4.56 }
          }
        }
      }

      expect(schema.(input).to_h).to eql(
        user:  {
          email: 'jane@doe.org',
          bdate: Date.new(2010, 9, 8),
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
      Dry::Validation.JSON do
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
