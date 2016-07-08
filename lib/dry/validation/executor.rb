module Dry
  module Validation
    class ProcessInput
      attr_reader :processor

      def initialize(processor)
        @processor = processor
      end

      def call(input, *)
        processor.(input)
      end
    end

    class ApplyRules
      attr_reader :rules

      def initialize(rules)
        @rules = rules
      end

      def call(input, result)
        result.update(rules.each_with_object({}) do |(name, rule), hash|
          hash[name] = rule.(input)
        end)
      end
    end

    class ApplyChecks < ApplyRules
      def call(input, result)
        result.update(rules.each_with_object({}) do |(name, check), hash|
          check_res = check.is_a?(Guard) ? check.(input, result) : check.(input)
          hash[name] = check_res if check_res
        end)
      end
    end

    class BuildErrors
      attr_reader :path

      def initialize(path)
        @path = Array[*path]
      end

      def call(_input, results)
        results
          .select { |_, result| result.failure? }
          .map { |name, result| Error.new(error_path(name), result) }
      end

      def error_path(name)
        full_path = path.dup
        full_path << name
        full_path.size > 1 ? full_path : full_path[0]
      end
    end

    class Executor
      attr_reader :steps

      def self.new(&block)
        super.tap do |executor|
          yield(executor.steps)
          executor.freeze
        end
      end

      def initialize
        @steps = []
      end

      def call(input, results)
        steps.reduce { |a, e| e.call(input, results) }
      end
    end
  end
end
