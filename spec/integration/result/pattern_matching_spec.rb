# frozen_string_literal: true

RSpec.describe Dry::Validation::Result do
  let(:params) do
    double(:params, message_set: [], to_h: { email: "jane@doe.org" })
  end

  let(:success) do
    Dry::Validation::Result.new(params, context)
  end

  let(:context) do
    context = Concurrent::Map.new
    context[:country] = "Sweden"
    context
  end

  it "supports pattern matching with keys" do
    case success
    in email:
      expect(email).to eql('jane@doe.org')
    end
  end

  it "supports pattern matching with arrays extracting keys and context"  do
    case success
    in [{ email: }, { country: }]
      expect(email).to eql("jane@doe.org")
      expect(country).to eql("Sweden")
    end
  end

  context "with monads" do
    before { Dry::Validation.load_extensions(:monads) }

    example "success" do
      case success.to_monad
      in Dry::Monads::Result::Success(email:)
        expect(email).to eql("jane@doe.org")
      end

      case success.to_monad
      in Dry::Monads::Result::Success([_, { country: }])
        expect(country).to eql("Sweden")
      end
    end
  end
end
