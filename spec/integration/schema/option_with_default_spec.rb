RSpec.describe Dry::Validation::Schema, 'defining schema context with option API' do
  shared_context 'valid schema with :db option' do
    before do
      DB = [{ email: 'jane@doe' }]
    end

    after do
      Object.send(:remove_const, :DB)
    end

    it 'uses external dependency set by option with a default value' do
      expect(schema.db).to be(DB)

      expect(schema.(email: 'jade@doe', contact: { email: 'jade2@doe' })).to be_success
      expect(schema.(email: 'jane@doe', contact: { email: 'jane2@doe' })).to be_failure
      expect(schema.(email: 'jade@doe', contact: { email: 'jane@doe' })).to be_failure
    end
  end


  context 'with a default value' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          option :db, -> { DB }

          def unique?(name, value)
            db.none? { |item| item[name] == value }
          end
        end

        required(:email).filled(unique?: :email)

        required(:contact).schema do
          required(:email).filled(unique?: :email)
        end
      end
    end

    include_context 'valid schema with :db option'
  end

  context 'without a default value' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          option :db

          def unique?(name, value)
            db.none? { |item| item[name] == value }
          end
        end

        required(:email).filled(unique?: :email)

        required(:contact).schema do
          required(:email).filled(unique?: :email)
        end
      end.with(db: DB)
    end

    include_context 'valid schema with :db option'
  end
end
