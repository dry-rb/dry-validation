# frozen_string_literal: true

require "zeitwerk"

require "dry/core"
require "dry/schema"

require "dry/validation/constants"

# Main namespace
#
# @api public
module Dry
  # Main library namespace
  #
  # @api public
  module Validation
    extend Dry::Core::Extensions

    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "dry-validation"
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/dry-validation.rb")
        loader.push_dir(root)
        loader.ignore(
          "#{root}/dry-validation.rb",
          "#{root}/dry/validation/schema_ext.rb",
          "#{root}/dry/validation/{constants,errors,version}.rb",
          "#{root}/dry/validation/extensions"
        )
        loader.inflector.inflect("dsl" => "DSL")
      end
    end

    register_extension(:monads) do
      require "dry/validation/extensions/monads"
    end

    register_extension(:hints) do
      require "dry/validation/extensions/hints"
    end

    register_extension(:predicates_as_macros) do
      require "dry/validation/extensions/predicates_as_macros"
    end

    # Define a contract and build its instance
    #
    # @example
    #   my_contract = Dry::Validation.Contract do
    #     params do
    #       required(:name).filled(:string)
    #     end
    #   end
    #
    #   my_contract.call(name: "Jane")
    #
    # @param [Hash] options Contract options
    #
    # @see Contract
    #
    # @return [Contract]
    #
    # @api public
    #
    def self.Contract(options = EMPTY_HASH, &block)
      Contract.build(options, &block)
    end

    # This is needed by Macros::Registrar
    #
    # @api private
    def self.macros
      Macros
    end

    loader.setup

    extend Macros::Registrar
  end
end
