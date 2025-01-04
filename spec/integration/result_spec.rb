# frozen_string_literal: true

RSpec.describe Dry::Validation::Result do
  describe "#inspect" do
    let(:params) do
      double(:params, message_set: [], to_h: {email: "jane@doe.org"})
    end

    it "returns a string representation" do
      result = Dry::Validation::Result.new(params) do |r|
        r.add_error(Dry::Validation::Message.new("not valid", path: :email))
      end

      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect(result.inspect).to eql('#<Dry::Validation::Result{email: "jane@doe.org"} errors={email: ["not valid"]}>')
      else
        expect(result.inspect).to eql('#<Dry::Validation::Result{:email=>"jane@doe.org"} errors={:email=>["not valid"]}>')
      end
    end
  end

  describe "#errors" do
    subject(:errors) { result.errors }

    let(:params) do
      double(:params, message_set: [], to_h: {email: "jane@doe.org"})
    end

    let(:result) do
      Dry::Validation::Result.new(params) do |r|
        r.add_error(Dry::Validation::Message.new("root error", path: [nil]))
        r.add_error(Dry::Validation::Message.new("email error", path: [:email]))
      end
    end

    describe "#[]" do
      it "returns error messages for the provided key" do
        expect(errors[:email]).to eql(["email error"])
      end

      it "returns [] for base errors" do
        expect(errors[nil]).to eql(["root error"])
      end
    end

    describe "#empty?" do
      let(:result) { Dry::Validation::Result.new(params) }

      it "returns the correct value whilst adding errors" do
        expect(result.errors).to be_empty
        result.add_error(Dry::Validation::Message.new("root error", path: [nil]))
        expect(result.errors).not_to be_empty
      end
    end
  end

  describe "#error?" do
    let(:schema_result) do
      double(:schema_result, message_set: [], to_h: {email: "jane@doe.org"})
    end

    let(:result) do
      Dry::Validation::Result.new(schema_result) do |r|
        r.add_error(Dry::Validation::Message.new("root error", path: [nil]))
        r.add_error(Dry::Validation::Message.new("email error", path: [:email]))
      end
    end

    it "reports an error on email" do
      expect(result.error?(:email)).to be(true)
    end

    it "reports an error on 'root' when asked for nil" do
      expect(result.error?([nil])).to be(true)
    end

    it "doesn't report errors on non existing keys" do
      expect(result.error?(:nonexistant)).to be(false)
    end
  end

  describe "#inspect" do
    let(:params) do
      double(:params, message_set: [], to_h: {})
    end

    let(:context) do
      context = Concurrent::Map.new
      context[:data] = "foo"
      context
    end

    let(:result) do
      Dry::Validation::Result.new(params, context)
    end

    example "results are inspectable" do
      expect(result.inspect).to be_a(String)
    end
  end
end
