require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Value < DSL
        attr_reader :type, :schema_class, :schema, :type_map

        def initialize(options = {})
          super
          @type = options.fetch(:type, :key)
          @schema_class = options.fetch(:schema_class, ::Class.new(Schema))
          @options = options.merge(type: @type, schema_class: @schema_class)
          @type_map = parent && parent.root? ? parent.type_map : {}
        end

        def predicates(mod)
          @registry = options[:registry] = schema_class.predicates(mod)
        end

        def input(*predicates)
          schema_class.config.input = predicates
          self
        end

        def key(name, &block)
          warn 'key is deprecated - use required instead.'

          required(name, &block)
        end

        def required(name, type_spec = nil, &block)
          rule = define(name, Key, &block)

          if type_spec
            type_map[name] = type_spec
          end

          rule
        end

        def schema(other = nil, &block)
          @schema = Schema.create_class(self, other, &block)
          type_map.update(@schema.type_map)
          hash?.and(@schema)
        end

        def each(*predicates, &block)
          left = array?

          right =
            if predicates.size > 0
              create_rule([:each, infer_predicates(predicates, new).to_ast])
            else
              val = Value[
                name, registry: registry, schema_class: schema_class.clone
              ].instance_eval(&block)

              if val.type_map?
                if root?
                  @type_map = [val.type_map]
                else
                  type_map[name] = [val.type_map]
                end
              end

              create_rule([:each, val.to_ast])
            end

          rule = left.and(right)

          add_rule(rule) if root?

          rule
        end

        def when(*predicates, &block)
          left = infer_predicates(predicates, Check[path, type: type, registry: registry])
          right = Value.new(type: type, registry: registry).instance_eval(&block)

          add_check(left.then(right.to_rule))

          self
        end

        def rule(id = nil, **options, &block)
          if id
            val = Value[id, registry: registry, schema_class: schema_class]
            res = val.instance_exec(&block)
          else
            id, deps = options.to_a.first
            val = Value[id, registry: registry, schema_class: schema_class]
            res = val.instance_exec(*deps.map { |path| val.value(id, path: path) }, &block)
          end

          add_check(val.with(rules: [res.with(name: id, deps: deps || [])]))
        end

        def confirmation
          conf = :"#{name}_confirmation"

          parent.optional(conf).maybe

          rule(conf => [conf, name]) do |left, right|
            left.eql?(right)
          end
        end

        def value(path, opts = {})
          check(name || path, { registry: registry, rules: rules, path: path }.merge(opts))
        end

        def check(name, options = {})
          Check[name, options.merge(type: type)]
        end

        def validate(**opts, &block)
          id, *deps = opts.to_a.flatten
          name = deps.size > 1 ? id : deps.first
          rule = create_rule([:check, [deps, [:custom, [id, block]]]], name).with(deps: deps)
          add_check(rule)
        end

        def configure(&block)
          schema_class.class_eval(&block)
          @registry = schema_class.registry
          self
        end

        def root?
          name.nil?
        end

        def type_map?
          ! type_map.empty?
        end

        def schema?
          ! @schema.nil?
        end

        def class
          Value
        end

        def new
          self.class.new(registry: registry, schema_class: schema_class.clone)
        end

        def key?(name)
          create_rule(predicate(:key?, name))
        end

        def node(input, *args)
          if input.is_a?(::Symbol)
            registry.ensure_valid_predicate(input, args, schema_class)
            [type, [name, predicate(input, args)]]
          elsif input.respond_to?(:rule)
            [type, [name, [:type, input]]]
          elsif input.is_a?(Schema)
            [type, [name, schema(input).to_ast]]
          else
            [type, [name, input.to_ast]]
          end
        end

        def dyn_arg?(name)
          !name.to_s.end_with?('?') && schema_class.instance_methods.include?(name)
        end

        def respond_to?(name)
          self.class.public_methods.include?(name)
        end

        def infer_predicates(predicates, infer_on = self)
          predicates.flat_map(&::Kernel.method(:Array)).map { |predicate|
            name, *args = ::Kernel.Array(predicate)

            if name.is_a?(Schema)
              infer_on.schema(name)
            elsif name.respond_to?(:rule)
              create_rule(name.rule.to_ast)
            else
              infer_on.__send__(name, *args)
            end
          }.reduce(:and)
        end

        private

        def method_missing(meth, *args, &block)
          return schema_class.instance_method(meth) if dyn_arg?(meth)

          val_rule = create_rule(predicate(meth, args))

          if block
            val = new.instance_eval(&block)

            type_map.update(val.type_map) if val.type_map?

            new_rule = create_rule([:and, [val_rule.to_ast, val.to_ast]])

            add_rule(new_rule)
          else
            val_rule
          end
        end
      end
    end
  end
end
