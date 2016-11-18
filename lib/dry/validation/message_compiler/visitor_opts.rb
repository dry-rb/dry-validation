module Dry
  module Validation
    class MessageCompiler
      class VisitorOpts < Hash
        def self.new
          opts = super
          opts[:path] = EMPTY_ARRAY
          opts[:rule] = nil
          opts[:message_type] = :failure
          opts
        end

        def path?
          ! path.empty?
        end

        def path
          self[:path]
        end

        def rule
          self[:rule]
        end

        def with_rule(new_rule, **other)
          opts = dup
          opts[:rule] = new_rule unless opts.rule
          opts.(other)
        end

        def call(other)
          merge(other.update(path: [*path, *other[:path]]))
        end
      end
    end
  end
end
