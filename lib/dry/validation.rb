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

      dsl_opts = {
        schema_class: schema_class,
        registry: schema_class.registry,
        parent: options[:parent]
      }

      dsl_ext = schema_class.config.dsl_extensions

      dsl = Schema::Value.new(dsl_opts)
      dsl_ext.__send__(:extend_object, dsl) if dsl_ext
      dsl.predicates(options[:predicates]) if options.key?(:predicates)
      dsl.instance_exec(&block) if block

      klass = dsl.schema_class

      rules = klass.config.rules + (options.fetch(:rules, []) + dsl.rules)

      if klass.config.input
        klass.config.input_rule = dsl.__send__(klass.config.input)
      end

      klass.configure do |config|
        config.rules = rules
        config.checks = config.checks + dsl.checks
        config.path = dsl.path
        config.type_map = klass.build_type_map(dsl.type_map) if config.type_specs
      end

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
