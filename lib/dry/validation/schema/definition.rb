require 'dry/validation/schema/buffer'

module Dry
  module Validation
    class Schema
      module Definition
        include DSL

        def target
          @target ||= Buffer.new(name)
        end

        def add_rule(rule)
          target.add_rule(rule)
          self
        end

        def to_ast
          target.rule_ast
        end

        def rules
          target.rules
        end

        def checks
          target.checks
        end
      end
    end
  end
end

require 'dry/validation/schema/rule'
require 'dry/validation/schema/value'
require 'dry/validation/schema/key'
require 'dry/validation/schema/attr'
