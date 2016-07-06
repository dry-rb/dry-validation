RSpec.describe Dry::Validation::Schema, 'defining an option with default value' do
  subject(:schema) do
    Dry::Validation.Schema do
      configure do
        option :db, -> { DB }

        def unique?(name, value)
          DB.none? { |item| item[name] == value }
        end
      end

      required(:email).filled(unique?: :email)
    end
  end

  before do
    DB = [{ email: 'jane@doe' }]
  end

  after do
    Object.send(:remove_const, :DB)
  end

  it 'uses external dependency set by option with a default value' do
    expect(schema.db).to be(DB)

    expect(schema.(email: 'jade@doe')).to be_success
    expect(schema.(email: 'jane@doe')).to be_failure
  end
end
