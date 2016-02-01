module Dry
  module Validation
    class Schema
      class Sourced
        include Dry::Equalizer(:id, :source, :target)

        attr_reader :source, :target, :id

        def self.new(source, target)
          if target.class == Sourced
            target.for(source)
          else
            super
          end
        end

        def initialize(source, target)
          @source = source
          @target = target
          @id = target.id
        end

        def for(source)
          self.class.new(source, target)
        end

        def add_rule(rule)
          target.add_rule(rule)
          self
        end

        def add_check(check)
          target.add_check(check)
          self
        end

        def to_ast
          target.to_ast
        end

        def key(*args, &block)
          target.key(*args, &block)
        end

        def optional(*args, &block)
          target.optional(*args, &block)
        end

        def attr(*args, &block)
          target.key(*args, &block)
        end

        def value(id)
          target.value(id)
        end

        def rule(id, &block)
          target.rule(id, &block)
          self
        end

        def rules
          target.rules
        end

        def checks
          target.checks
        end

        private

        def method_missing(meth, *args, &block)
          response = source.__send__(meth, *args, &block)
          self.class.new(response, target)
        end
      end
    end
  end
end
