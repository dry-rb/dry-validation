module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node, :type, :target, :keys, :options

        class Check < Rule
          def class
            Schema::Rule::Check
          end

          private

          def method_missing(meth, *args)
            new([:check, [name, [:predicate, [name, [meth]]]]])
          end
        end

        class Result < Rule
          def class
            Schema::Rule::Result
          end

          private

          def method_missing(meth, *args)
            if args.size > 0
              pred_args = args.map { |value|
                value.class <= Schema::Rule ? [:res_arg, value.name] : [:arg, value]
              }

              names = args
                .map { |value| value.class <= Schema::Rule && value.name }
                .compact

              new_rule = new([:res, [name, [:predicate, [meth, [:args, pred_args]]]]])

              if names.size > 0
                new_rule.with(keys: [name]+names)
              else
                new_rule
              end
            else
              new([:res, [name, [:predicate, [meth, args]]]])
            end
          end
        end

        def initialize(name, node, options = {})
          @node = node
          @target = Buffer::Sourced.new(self, options.fetch(:target))
          @keys = options.fetch(:keys, [name])
          @type = options.fetch(:type, :and)
          @options = options
          @name = target.id && name.is_a?(::Symbol) ? { target.id => name } : name
        end

        def class
          Schema::Rule
        end

        def to_ast
          node
        end
        alias_method :to_ary, :to_ast

        def to_check
          Rule::Check.new(
            name, [:check, [name, [:predicate, [name, []]]]], options
          )
        end

        def to_implication
          with(type: :then)
        end

        def required(*predicates)
          rule = ([val(:filled?)] + infer_predicates(predicates)).reduce(:and)

          target.add_rule(__send__(type, rule))
        end

        def maybe(*predicates)
          rule =
            if predicates.size > 0
              val(:none?).or(infer_predicates(predicates).reduce(:and))
            else
              val(:none?).or(val(:filled?))
            end

          target.add_rule(__send__(type, rule))
        end

        def when(*args, &block)
          predicates, rule_name = args

          left = ::Kernel.Array(predicates).map { |predicate|
            target.value(name).__send__(*::Kernel.Array(predicate))
          }.reduce(:and)

          right = yield

          right.target.rule(rule_name || right.name) { left.then(right) }
        end

        def confirmation
          conf = :"#{name}_confirmation"

          target.key(conf).maybe

          target.rule(conf) do
            target.value(name).filled?.then(target.value(conf).eql?(target.value(name)))
          end
        end

        def not
          new([:not, node])
        end

        def and(other)
          new_from([:and, [node, other.to_ast]], other)
        end
        alias_method :&, :and

        def or(other)
          new_from([:or, [node, other.to_ast]], other)
        end
        alias_method :|, :or

        def xor(other)
          new_from([:xor, [node, other.to_ast]], other)
        end
        alias_method :^, :xor

        def then(other)
          new_from([:implication, [node, other.to_ast]], other)
        end
        alias_method :>, :then

        def with(new_options)
          self.class.new(name, node, options.merge(new_options))
        end

        private

        def infer_predicates(predicates)
          predicates.map do |predicate|
            name, args = ::Kernel.Array(predicate).flatten
            val(name, ::Kernel.Array(args))
          end
        end

        def val(predicate, args = [])
          new([:val, [name, [:predicate, [predicate, args]]]])
        end

        def new_from(node, other)
          self.class.new(
            name,
            node,
            options.merge(target: target, keys: (keys + other.keys).uniq)
          )
        end

        def new(node, name = self.name)
          self.class.new(name, node, options)
        end
      end
    end
  end
end
