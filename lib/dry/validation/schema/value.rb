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
          @type_map = {}
        end

        def key(name, &block)
          ::Kernel.warn 'key is deprecated - use required instead.'

          required(name, &block)
        end

        def required(name, &block)
          define(name, Key, &block)
        end

        def schema(other = nil, &block)
          @schema = Schema.create_class(self, other, &block)
          hash?.and(@schema)
        end

        def each(*predicates, &block)
          left = array?

          right =
            if predicates.size > 0
              create_rule([:each, infer_predicates(predicates, new).to_ast])
            else
              val = Value[name, registry: registry].instance_eval(&block)
              create_rule([:each, val.to_ast])
            end

          rule = left.and(right)

          add_rule(rule) if root?

          rule
        end

        def when(*predicates, &block)
          left = infer_predicates(predicates, Check[path, type: type, registry: registry])

          right = Value.new(type: type, registry: registry)
          right.instance_eval(&block)

          add_check(left.then(create_rule(right.to_ast)))

          self
        end

        def rule(id = nil, **options, &block)
          if id
            val = Value[id, registry: registry]
            res = val.instance_exec(&block)
          else
            id, deps = options.to_a.first
            val = Value[id, registry: registry]
            res = val.instance_exec(*deps.map { |name| val.value(name) }, &block)
          end

          add_check(val.with(rules: [res.with(deps: deps || [])]))
        end

        def confirmation
          conf = :"#{name}_confirmation"

          parent.optional(conf).maybe

          rule(conf => [conf, name]) { |left, right| left.eql?(right) }
        end

        def value(name)
          check(name, registry: registry, rules: rules)
        end

        def check(name, options = {})
          Check[name, options.merge(type: type)]
        end

        def configure(&block)
          klass = ::Class.new(schema_class, &block)
          @schema_class = klass
          @registry = klass.registry
          self
        end

        def root?
          name.nil?
        end

        def schema?
          ! @schema.nil?
        end

        def class
          Value
        end

        def new
          self.class.new(registry: registry)
        end

        def predicate(name, *args)
          registry.ensure_valid_predicate(name, args)
          registry[name].curry(*args)
        end

        def node(input, *args)
          if input.is_a?(::Symbol)
            [type, [name, predicate(input, *args).to_ast]]
          elsif input.respond_to?(:rule)
            [type, [name, [:type, input]]]
          elsif input.is_a?(::Class) && input < ::Dry::Types::Struct
            [type, [name, [:schema, Schema.create_class(self, input)]]]
          else
            [type, [name, input.to_ast]]
          end
        end

        private

        def infer_predicates(predicates, infer_on)
          predicates.reduce(infer_on) { |a, e|
            args = e.is_a?(::Hash) ? e.first : ::Kernel.Array(e)
            a.__send__(*args)
          }
        end

        def method_missing(meth, *args, &block)
          val_rule = create_rule([:val, predicate(meth, *args).to_ast])

          if block
            val = new.instance_eval(&block)
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
