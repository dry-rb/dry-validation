require 'delegate'
require 'dry/validation/schema/dsl'

module Dry
  module Validation
    class Schema
      class Buffer
        include Dry::Equalizer(:name, :rules, :checks)
        include DSL

        attr_reader :name, :rules, :checks

        class Sourced
          include Dry::Equalizer(:name, :source, :buffer)

          attr_reader :source, :buffer, :name

          def initialize(source, buffer)
            @source = source
            @buffer = buffer
            @name = buffer.name
          end

          def add_rule(rule)
            buffer.add_rule(rule)
            self
          end

          def add_check(check)
            buffer.add_check(check)
            self
          end

          def to_ast
            buffer.to_ast
          end

          def rule_ast
            buffer.rule_ast
          end

          def key(*args, &block)
            buffer.key(*args, &block)
          end

          def optional(*args, &block)
            buffer.optional(*args, &block)
          end

          def attr(*args, &block)
            buffer.key(*args, &block)
          end

          def value(name)
            buffer.value(name)
          end

          def rule(name, &block)
            buffer.rule(name, &block)
            self
          end

          def rules
            buffer.rules
          end

          def checks
            buffer.checks
          end

          private

          def method_missing(meth, *args, &block)
            response = source.__send__(meth, *args, &block)
            self.class.new(response, buffer)
          end
        end

        def initialize(name)
          @name = name
          @rules = []
          @checks = []
        end

        def add_rule(rule)
          rules << rule
          self
        end

        def add_check(check)
          checks << check
          self
        end

        def to_ast
          rules.map(&:to_ast)
        end

        def rule_ast
          rules.size > 1 ? [:set, [name, to_ast]] : to_ast[0]
        end
      end
    end
  end
end
