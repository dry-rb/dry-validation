module Dry
  module Validation
    class Schema
      module Definition
        def schema(name, &block)
          schema = Class.new(superclass)
          schema.key(name, &block)
          schemas << schema
          self
        end

        def key(name, &block)
          Key.new(name, rules).key?(&block)
        end

        def optional(name, &block)
          Key.new(name, rules).optional(&block)
        end

        def rule(name, **options, &block)
          if block
            gen_name, rule_names = name.to_a.first
            gen_rule = yield(*rule_names.map { |rule| rule_by_name(rule).to_generic })

            generics << Schema::Rule.new(gen_name, [:rule, [gen_name, gen_rule.to_ary]])
          else
            predicate, rule_names = options.to_a.first
            identifier = { name => rule_names }

            groups << [:group, [identifier, [:predicate, predicate]]]
          end
        end

        def confirmation(name)
          identifier = :"#{name}_confirmation"

          key(name, &:filled?)
          key(identifier, &:filled?)

          rule(identifier, eql?: [name, identifier])
        end

        private

        def rule_by_name(name)
          rules.detect { |rule| rule.name == name }
        end
      end
    end
  end
end

require 'dry/validation/schema/rule'
require 'dry/validation/schema/value'
require 'dry/validation/schema/key'
