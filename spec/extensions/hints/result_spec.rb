# frozen_string_literal: true
require 'stringio'

RSpec.describe Dry::Validation::Result do
  before { Dry::Validation.load_extensions(:hints) }

  let(:schema) do
    Class.new(Dry::Validation::Contract) do
      schema do
        required(:name).filled(:string, size?: 2..4)
      end

      rule(:name) do
        key.failure("oops") if values[:name] != "Jane"
      end
    end.new
  end

  let(:result) { schema.(input) }

  context "with valid input" do
    let(:input) { {name: "Jane"} }

    describe "#success?" do
      it "returns true" do
        expect(result).to be_success
      end
    end

    describe "#hints" do
      it "returns an empty array" do
        expect(result.hints).to be_empty
      end
    end
  end

  context "with invalid input" do
    let(:input) { {name: ""} }

    describe "#failure?" do
      it "returns true" do
        expect(result).to be_failure
      end
    end

    describe "#hints" do
      it "returns hint messages excluding errors" do
        expect(result.hints.to_h).to eql(name: ["length must be within 2 - 4"])
      end
    end

    describe "#messages" do
      it "returns hints + error messages" do
        expect(result.messages.to_h).to eql(name: ["must be filled", "length must be within 2 - 4"])
      end

      describe 'yaml translations backend' do
        let (:yaml_messages) do
          <<~HEREDOC
          en:
            dry_validation:
              errors:
                filled?: "must be filled"
                size?: "length must be within 2 - 4"

          de:
            dry_validation:
              errors:
                filled?: "de - must be filled"
                size?: "de - length must be within 2 - 4"
          HEREDOC
        end

        # FIXME: this is flaky and passes when run in isolation :(
        xit 'returns the correct translations' do
          allow(YAML).to receive(:load_file).and_return(YAML.load(StringIO.new(yaml_messages)))
          expect(result.errors(locale: :de).to_h).to eql(name: ['de - must be filled'])
          expect(result.messages(locale: :de).to_h).to eql(name: ["de - must be filled", "de - length must be within 2 - 4"])
          expect(result.errors(locale: :en).to_h).to eql(name: ['must be filled'])
          expect(result.messages(locale: :en).to_h).to eql(name: ["must be filled", "length must be within 2 - 4"])
        end
      end
    end

    describe "#errors" do
      it "returns errors excluding hints" do
        expect(result.errors.to_h).to eql(name: ["must be filled"])
      end
    end
  end
end
