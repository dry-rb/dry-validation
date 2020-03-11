# frozen_string_literal: true

require "dry/validation/values"

RSpec.describe Dry::Validation::Values do
  subject(:values) do
    Dry::Validation::Values.new(data)
  end

  let(:data) do
    {name: "Jane", address: {city: "Paris", geo: {lat: 1, lon: 2}}, phones: [123, 431]}
  end

  describe "#[]" do
    it "works with a symbol" do
      expect(values[:name]).to eql("Jane")
    end

    it "works with a dot-notation path" do
      expect(values["address.city"]).to eql("Paris")
    end

    it "works with a path" do
      expect(values[:address, :city]).to eql("Paris")
    end

    it "works with a hash" do
      expect(values[address: :city]).to eql("Paris")
    end

    it "works with a hash pointing to multiple values" do
      expect(values[address: {geo: [:lat, :lon]}]).to eql([1, 2])
    end

    it "works with an array" do
      expect(values[%i[address city]]).to eql("Paris")
    end

    it "raises on unpexpected argument type" do
      expect { values[123] }
        .to raise_error(
          ArgumentError, "+key+ must be a valid path specification"
        )
    end

    it "accepts missing keys returning nil" do
      expect(values[address: {geo: [:population, :lon]}]).to eql([nil, 2])
    end
  end

  describe "#key?" do
    it "returns true when a symbol key is present" do
      expect(values.key?(:name)).to be(true)
    end

    it "returns false when a symbol key is not present" do
      expect(values.key?(:not_here)).to be(false)
    end

    it "returns true when a nested key is present" do
      expect(values.key?([:address, :city])).to be(true)
    end

    it "returns false when a nested key is not present" do
      expect(values.key?([:address, :not_here])).to be(false)
    end

    it "returns true when nested keys are all present" do
      expect(values.key?([:address, :geo, [:lat, :lon]])).to be(true)
    end

    it "returns false when nested keys are not all present" do
      expect(values.key?([:address, :geo, [:lat, :lon, :other]])).to be(false)
    end

    it "returns true when a path to an array element is present" do
      expect(values.key?([:phones, 1])).to be(true)
    end

    it "returns false when a path to an array element is not present" do
      expect(values.key?([:phones, 5])).to be(false)
    end
  end

  describe "#dig" do
    it "returns a value from a nested hash when it exists" do
      expect(values.dig(:address, :city)).to eql("Paris")
    end

    it "returns nil otherwise" do
      expect(values.dig(:oops, :not_here)).to be(nil)
    end
  end

  describe "#method_missing" do
    it "forwards to data" do
      result = []

      values.each do |k, v|
        result << [k, v]
      end

      expect(result).to eql(values.to_a)
    end

    it "raises NoMethodError when data does not respond to the meth" do
      expect { values.not_really_implemented }
        .to raise_error(NoMethodError, /not_really_implemented/)
    end
  end

  describe "#method" do
    it "returns Method objects for a forwarded method" do
      expect(values.method(:dig)).to be_instance_of(Method)
    end
  end
end
