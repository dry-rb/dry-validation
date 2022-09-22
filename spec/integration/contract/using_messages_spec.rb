# frozen_string_literal: true

require "dry/validation/contract"

RSpec.describe Dry::Validation::Contract do
  shared_context "translated messages" do
    subject(:contract) do
      contract_class.new
    end

    let(:locales) { %i[en] }

    let(:contract_class) do
      backend = self.backend
      locales = self.locales

      Class.new(Dry::Validation::Contract) do
        configure { |c| c.messages.backend = backend }

        locales.each do |l|
          config.messages.load_paths << SPEC_ROOT.join("fixtures/messages/errors.#{l}.yml").realpath
        end

        params do
          required(:email).filled(:string, min_size?: 3, max_size?: 100)
        end

        rule(:email) do
          key.failure(:invalid) unless value.include?("@")
          key.failure(:taken, values.to_h) if value == "jane@doe.org"
        end
      end
    end

    it "configures messages for the schema" do
      expect(contract.schema.config.messages.load_paths)
        .to eql(contract.class.config.messages.load_paths)
    end

    describe "result errors" do
      it "supports full: true option for schema errors" do
        expect(contract.call(email: "").errors(full: true).map(&:to_s))
          .to eql(["E-mail must be filled"])
      end

      it "supports full: true option for contract errors" do
        expect(contract.call(email: "jane").errors(full: true).map(&:to_s))
          .to eql(["E-mail oh noez bad email"])
      end
    end

    describe "failure" do
      it "uses messages for failures" do
        expect(contract.call(email: "foo").errors.to_h)
          .to eql(email: ["oh noez bad email"])
      end

      it "passes tokens to message templates" do
        expect(contract.call(email: "jane@doe.org").errors.to_h)
          .to eql(email: ["looks like jane@doe.org is taken"])
      end
    end
  end

  context "using :yaml messages" do
    let(:backend) { :yaml }

    include_context "translated messages"
  end

  context "using :i18n messages" do
    include_context "translated messages" do
      let(:backend) { :i18n }
      let(:locales) { %i[en pl] }

      before do
        contract_class
        I18n.available_locales = locales
      end

      it "respects I18n.with_locale" do
        I18n.with_locale(:pl) do
          expect(contract.call(email: "foo").errors.to_h).to eql(email: ["oh nie zły email"])
        end

        I18n.with_locale(:en) do
          expect(contract.call(email: "foo").errors.to_h).to eql(email: ["oh noez bad email"])
        end

        expect(contract.call(email: "foo").errors(locale: :pl).to_h).to eql(email: ["oh nie zły email"])
        expect(contract.call(email: "foo").errors.to_h).to eql(email: ["oh noez bad email"])
      end
    end
  end

  it "parses array tokens as a comma separated list" do
    contract = Class.new(Dry::Validation::Contract) do
      config.messages.load_paths << SPEC_ROOT.join("fixtures/messages/errors.en.yml").realpath

      params do
        required(:age).filled(:integer)
      end

      rule(:age) do
        list = [1, 2, 3]
        key.failure(:toddler, list: list) unless list.include?(value)
      end
    end

    expect(contract.new.call(age: 4).errors.to_h).to eql(age: ["should be included in 1, 2, 3"])
  end
end
