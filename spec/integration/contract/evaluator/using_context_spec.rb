# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator, "using context" do
  before(:all) do
    Dry::Validation.load_extensions(:hints)
  end

  context "when key does not exist" do
    subject(:contract) { contract_class.new }

    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:email).filled(:string)
          required(:user_id).filled(:integer)
        end

        rule(:user_id) do |context:|
          if values[:user_id].equal?(312)
            context[:user] = "jane"
          else
            key(:user).failure("must be jane")
          end
        end

        rule(:email) do |context:|
          key.failure("is invalid") if context[:user] == "jane" && values[:email] != "jane@doe.org"
        end
      end
    end

    it "stores new values between rule execution" do
      expect(contract.(user_id: 3, email: "john@doe.org").errors.to_h).to eql(user: ["must be jane"])
      expect(contract.(user_id: 312, email: "john@doe.org").errors.to_h).to eql(email: ["is invalid"])
    end

    it "exposes context in result" do
      expect(contract.(user_id: 312, email: "jane@doe.org").context.each.to_h).to eql(user: "jane")
    end

    it "uses the initial context" do
      expect(contract.({user_id: 312}, context: {name: "John"}).context.each.to_h)
        .to eql(user: "jane", name: "John")
    end

    context "when default context is defined" do
      subject(:contract) do
        contract_class.new(default_context: {user: "Redefined", name: "Redefined", details: "Present"})
      end

      it "initial context redefines it" do
        expect(contract.({user_id: 312}, context: {name: "John"}).context.each.to_h)
          .to eql(user: "jane", name: "John", details: "Present")
      end
    end

  end
end
