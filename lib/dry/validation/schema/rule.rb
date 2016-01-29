require 'dry/validation/schema/sourced'

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
          def self.with_current_rule(rule, &block)
            @current_rule = rule
            yield
          ensure
            @current_rule = nil
          end

          def self.current_rule
            @current_rule
          end

          def class
            Schema::Rule::Result
          end

          def current_rule
            self.class.current_rule
          end

          private

          def method_missing(meth, *args)
            new_rule =
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

            if current_rule
              add_check(current_rule.then(new_rule).to_check(name))
            end

            new_rule
          end
        end

        def initialize(name, node, options = {})
          @node = node
          @target = Schema::Sourced.new(self, options.fetch(:target))
          @keys = options.fetch(:keys, [name])
          @type = options.fetch(:type, :and)
          @options = options
          @name = name.is_a?(::Hash) || target.id == name ? name : { target.id => name }
        end

        def current_rule
          target.current_rule
        end

        def add_rule(rule)
          target.add_rule(rule)
        end

        def add_check(rule)
          target.add_check(rule)
        end

        def rules
          target.rules
        end

        def checks
          target.checks
        end

        def rule(name, &block)
          target.rule(name, &block)
        end

        def value(name)
          Rule::Result.new(name, [], target: target)
        end

        def class
          Schema::Rule
        end

        def to_ast
          node
        end
        alias_method :to_ary, :to_ast

        def to_check(name = self.name)
          Rule::Check.new(name, [:check, [name, node, keys]], options)
        end

        def to_success_check
          Rule::Check.new(
            name, [:check, [name, [:predicate, [name, []]]]], options
          )
        end

        def to_implication
          with(type: :then)
        end

        def required(*predicates)
          rule = ([val(:filled?)] + infer_predicates(predicates)).reduce(:and)

          add_rule(__send__(type, rule))
        end

        def maybe(*predicates)
          rule =
            if predicates.size > 0
              val(:none?).or(infer_predicates(predicates).reduce(:and))
            else
              val(:none?).or(val(:filled?))
            end

          add_rule(__send__(type, rule))
        end

        def when(*predicates, &block)
          left = ::Kernel.Array(predicates).map { |predicate|
            target.value(name).__send__(*::Kernel.Array(predicate))
          }.reduce(:and)

          Rule::Result.with_current_rule(left, &block)
        end

        def confirmation
          conf = :"#{name}_confirmation"

          key = Value.new(conf).key(conf).maybe
          val = key.value(conf)

          result = self.when(:filled?) { val.eql?(value(name)) }

          rules.concat(val.rules)
          checks.concat(val.checks)

          result
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
