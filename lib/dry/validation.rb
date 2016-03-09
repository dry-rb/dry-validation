require 'dry-equalizer'
require 'dry-configurable'
require 'dry-container'

require 'dry/validation/schema'
require 'dry/validation/schema/form'
require 'dry/validation/model'

module Dry
  module Validation
    def self.messages_paths
      Messages::Abstract.config.paths
    end

    def self.Schema(base = Schema, **options, &block)
      dsl_opts = {
        schema_class: Class.new(base.is_a?(Schema) ? base.class : base)
      }

      dsl = Schema::Value.new(dsl_opts)
      dsl.instance_exec(&block)

      klass = dsl.schema_class

      klass.configure do |config|
        config.rules = config.rules + (options.fetch(:rules, []) + dsl.rules)
        config.checks = config.checks + dsl.checks
        config.path = options[:path]
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
  end
end
