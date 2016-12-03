require 'dry/core/extensions'
require 'dry/core/constants'

module Dry
  module Validation
    extend Dry::Core::Extensions
    include Dry::Core::Constants

    MissingMessageError = Class.new(StandardError)
    InvalidSchemaError = Class.new(StandardError)

    def self.messages_paths
      Messages::Abstract.config.paths
    end

    def self.Schema(base = Schema, **options, &block)
      schema_class = Class.new(base.is_a?(Schema) ? base.class : base)
      klass = schema_class.define(options.merge(schema_class: schema_class), &block)

      if options[:build] == false
        klass
      else
        klass.new
      end
    end

    def self.Form(base = nil, **options, &block)
      klass = base ? Schema::Form.configure(Class.new(base)) : Schema::Form
      Validation.Schema(klass, options, &block)
    end

    def self.JSON(base = Schema::JSON, **options, &block)
      klass = base ? Schema::JSON.configure(Class.new(base)) : Schema::JSON
      Validation.Schema(klass, options, &block)
    end
  end
end

require 'dry/validation/schema'
require 'dry/validation/schema/form'
require 'dry/validation/schema/json'
require 'dry/validation/extensions'
require 'dry/validation/version'
