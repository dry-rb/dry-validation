module Dry
  module Validation
    class ProcessInput
      attr_reader :processor

      def initialize(processor)
        @processor = processor
      end

      def call(input, result)
        [processor.(input), result]
      end
    end

    class ApplyInputRule
      attr_reader :rule

      def initialize(rule)
        @rule = rule
      end

      def call(input, result)
        rule_res = rule.(input)
        result.update(nil => rule_res) unless rule_res.success?
        [input, result]
      end
    end

    class ApplyRules
      attr_reader :rules

      def initialize(rules)
        @rules = rules
      end

      def call(input, result)
        rules.each_with_object(result) do |(name, rule), hash|
          hash[name] = rule.(input)
        end
        [input, result]
      end
    end

    class ApplyChecks < ApplyRules
      def call(input, result)
        rules.each_with_object(result) do |(name, check), hash|
          check_res = check.is_a?(Guard) ? check.(input, result) : check.(input)
          hash[name] = check_res if check_res
        end
        [input, result]
      end
    end

    class BuildErrors
      attr_reader :path

      def initialize(path)
        @path = Array[*path]
      end

      def call(input, result)
        errors = result
          .select { |_, r| r.failure? }
          .map { |name, r| Error.new(error_path(name), r) }
        [input, errors]
      end

      def error_path(name)
        full_path = path.dup
        full_path << name
        full_path.size > 1 ? full_path : full_path[0]
      end
    end

    class Executor
      attr_reader :steps, :final

      def self.new(path, &block)
        super(BuildErrors.new(path)).tap do |executor|
          yield(executor.steps)
          executor.freeze
        end
      end

      def initialize(final)
        @steps = []
        @final = final
      end

      def call(*args)
        output, response = steps.reduce(args) do |(input, result), s|
          return final.(input, result) if result.key?(nil)
          s.call(input, result)
        end
        final.(output, response)
      end
    end
  end
end
