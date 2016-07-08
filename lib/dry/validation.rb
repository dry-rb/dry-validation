require 'dry-equalizer'
require 'dry-configurable'
require 'dry-container'

require 'dry/validation/schema'
require 'dry/validation/schema/form'
require 'dry/validation/schema/json'

module Dry
  # FIXME: move this to dry-logic if it works lol
  require 'dry/logic/predicate'
  module Logic
    class Predicate
      class Curried < Predicate
        def evaluate_args!(schema)
          @args = args.map { |arg|
            arg.is_a?(UnboundMethod) ? arg.bind(schema).() : arg
          }
          self
        end
      end

      def evaluate_args!(*)
        self
      end
    end
  end

  module Validation
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

    def self.Form(options = {}, &block)
      Validation.Schema(Schema::Form, options, &block)
    end

    def self.JSON(options = {}, &block)
      Validation.Schema(Schema::JSON, options, &block)
    end
  end
end
