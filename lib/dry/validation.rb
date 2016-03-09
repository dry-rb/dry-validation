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

    def self.Schema(options = {}, &block)
      dsl_opts = { schema_class: Class.new(options.fetch(:type, Schema)) }

      dsl = Schema::Value.new(dsl_opts)
      dsl.instance_exec(&block)

      klass = dsl.schema_class

      klass.configure do |config|
        config.rules = options.fetch(:rules, []) + dsl.rules
        config.checks = dsl.checks
        config.path = options[:path]
      end

      if options[:build] == false
        klass
      else
        klass.new
      end
    end

    def self.Form(options = {}, &block)
      Validation.Schema(options.merge(type: Schema::Form), &block)
    end
  end
end
