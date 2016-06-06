require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Value < DSL
        attr_reader :type, :schema_class, :schema

        def initialize(options = {})
          super
          @type = options.fetch(:type, :key)
          @schema_class = options.fetch(:schema_class, ::Class.new(Schema))
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
              create_rule([:each, infer_predicates(predicates, Value.new).to_ast])
            else
              val = Value[name].instance_eval(&block)

              create_rule([:each, val.to_ast])
            end

          rule = left.and(right)

          add_rule(rule) if root?

          rule
        end

        def when(*predicates, &block)
          left = infer_predicates(predicates, Check[path, type: type])
          right = Value.new(type: type)
          right.instance_eval(&block)

          add_check(left.then(create_rule(right.to_ast)))

          self
        end

        def rule(id = nil, **options, &block)
          if id
            val = Value[id]
            res = val.instance_exec(&block)
          else
            id, deps = options.to_a.first
            val = Value[id]
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
          check(name, rules: rules)
        end

        def check(name, options = {})
          Check[name, options.merge(type: type)]
        end

        def configure(&block)
          klass = ::Class.new(schema_class, &block)
          @schema_class = klass
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

        private
        def infer_predicates(predicates, infer_on)
          predicates.reduce(infer_on) { |a, e|
            args = e.is_a?(::Hash) ? e.first : ::Kernel.Array(e)
            a.__send__(*args)
          }
        end

        def method_missing(meth, *args, &block)
          val_rule = create_rule([:val, [:predicate, [meth, args]]])

          if block
            val = Value.new.instance_eval(&block)
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
