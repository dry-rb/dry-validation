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

        def attr(name, &block)
          Attr.new(name, rules).attr?(&block)
        end

        def optional(name, &block)
          Key.new(name, rules).optional(&block)
        end

        def value(name)
          Schema::Rule::Result.new(name, [])
        end

        def rule(name, **options, &block)
          if options.any?
            predicate, rule_names = options.to_a.first
            identifier = { name => rule_names }

            groups << [:group, [identifier, [:predicate, predicate]]]
          else
            if block
              checks << Schema::Rule.new(name, [:check, [name, yield.to_ary]])
            else
              rule_by_name(name).to_check
            end
          end
        end

        def confirmation(name)
          identifier = { name => :confirmation }
          conf_name = :"#{name}_confirmation"

          key(name, &:filled?)
          key(conf_name, &:filled?)

          rule(identifier, eql?: [name, conf_name])
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
require 'dry/validation/schema/attr'
