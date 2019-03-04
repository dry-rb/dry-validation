# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '.option' do
  subject(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      option :db

      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        failure('is taken') unless db.unique?(values[:email])
      end
    end
  end

  let(:db) { double(:db) }

  it 'allows injecting objects to the constructor' do
    expect(db).to receive(:unique?).with('jane@doe.org').and_return(false)

    contract = contract_class.new(db: db)

    expect(contract.(email: 'jane@doe.org').errors).to eql(email: ['is taken'])
  end
end
