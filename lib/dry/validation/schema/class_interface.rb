require 'dry/configurable'
require 'dry/validation/messages'
require 'dry/validation/type_specs'

module Dry
  module Validation
    class Schema
      extend Dry::Configurable
      extend TypeSpecs

      NOOP_INPUT_PROCESSOR = -> input { input }

      setting :path
      setting :predicates, Logic::Predicates
      setting :registry
      setting :messages, :yaml
      setting :messages_file
      setting :namespace
      setting :rules, []
      setting :checks, []
      setting :options, {}
      setting :input, nil
      setting :input_rule, nil
      setting :dsl_extensions, nil

      setting :input_processor_map, {
        sanitizer: InputProcessorCompiler::Sanitizer.new,
        json: InputProcessorCompiler::JSON.new,
        form: InputProcessorCompiler::Form.new,
      }.freeze

      setting :type_specs, false

      def self.new(rules = config.rules, **options)
        super(rules, default_options.merge(options))
      end

      def self.define(options = {}, &block)
        source = options.fetch(:schema_class)
        config = source.config

        dsl_ext = config.dsl_extensions

        options = options.merge(rules: options[:rules].dup) if options.key?(:rules)
        dsl = Schema::Value.new(options.merge(registry: source.registry))
        dsl_ext.__send__(:extend_object, dsl) if dsl_ext
        dsl.predicates(options[:predicates]) if options.key?(:predicates)
        dsl.instance_exec(&block) if block

        target = dsl.schema_class

        if config.input
          config.input_rule = -> predicates {
            Schema::Value.new(registry: predicates).infer_predicates(Array(target.config.input)).to_ast
          }
        end

        rules = target.config.rules + (options.fetch(:rules, []) + dsl.rules)

        target.configure do |cfg|
          cfg.rules = rules
          cfg.checks = cfg.checks + dsl.checks
          cfg.path = dsl.path
          cfg.type_map = target.build_type_map(dsl.type_map) if cfg.type_specs
        end

        target
      end

      def self.define!(options = {}, &block)
        define(schema_class: self, &block)
      end

      def self.predicates(predicate_set = nil)
        if predicate_set
          config.predicates = predicate_set
          set_registry!
        else
          config.predicates
        end
      end

      def self.option(name, default = nil)
        attr_reader(*name)
        options.update(name => default)
      end

      def self.create_class(target, other = nil, &block)
        klass =
          if other.is_a?(self)
            Class.new(other.class)
          elsif other.respond_to?(:schema) && other.schema.is_a?(self)
            Class.new(other.schema.class)
          else
            Validation.Schema(target.schema_class, parent: target, build: false, &block)
          end

        klass.config.path = target.path if other
        klass.config.input_processor = :noop

        klass
      end

      def self.clone
        klass = Class.new(self)
        klass.config.rules = []
        klass.config.registry = registry
        klass
      end

      def self.to_ast
        [:schema, self]
      end

      def self.registry
        config.registry
      end

      def self.type_map
        config.type_map
      end

      def self.rules
        config.rules
      end

      def self.options
        config.options
      end

      def self.messages
        default = default_messages

        if config.messages_file && config.namespace
          default.merge(config.messages_file).namespaced(config.namespace)
        elsif config.messages_file
          default.merge(config.messages_file)
        elsif config.namespace
          default.namespaced(config.namespace)
        else
          default
        end
      end

      def self.default_messages
        case config.messages
        when :yaml then Messages.default
        when :i18n then Messages::I18n.new
        else
          raise "+#{config.messages}+ is not a valid messages identifier"
        end
      end

      def self.message_compiler
        @message_compiler ||= MessageCompiler.new(messages)
      end

      def self.rule_ast
        @rule_ast ||= config.rules.map(&:to_ast)
      end

      def self.default_options
        @default_options ||= { predicate_registry: registry,
          message_compiler: message_compiler,
          input_processor: input_processor,
          checks: config.checks }
      end

      def self.inherited(klass)
        super

        klass.config.options = klass.config.options.dup

        if registry && self != Schema
          klass.config.registry = registry.new(self)
        else
          klass.set_registry!
        end
      end

      def self.set_registry!
        config.registry = PredicateRegistry[self, config.predicates]
      end
    end
  end
end
