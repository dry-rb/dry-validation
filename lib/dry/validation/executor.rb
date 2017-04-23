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

    class ApplyInputRule
      attr_reader :rule

      def initialize(rule)
        @rule = rule
      end

      def call(input, result)
        rule_res = rule.(input)
        result.update(nil => rule_res) unless rule_res.success?
        input
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
        input
      end
    end

    class ApplyChecks < ApplyRules
      def call(input, result)
        rules.each_with_object(result) do |(name, checks), hash|
          checks.each do |check|
            check_res = check.is_a?(Guard) ? check.(input, result) : check.(input)
            if hash.key?(name)
              if hash[name].is_a?(Array)
                hash[name] << check_res
              else
                hash[name] = [hash[name], check_res]
              end
            else
              hash[name] = check_res if check_res
            end
          end
        end
        input
      end
    end

    class BuildErrors
      def call(result)
        result.values.flatten.compact.select(&:failure?)
      end
    end

    class Executor
      attr_reader :steps, :final

      def self.new(&block)
        super(BuildErrors.new).tap { |executor| yield(executor.steps) }.freeze
      end

      def initialize(final)
        @steps = []
        @final = final
      end

      def call(input, result = {})
        output = steps.reduce(input) do |a, e|
          return [a, final.(result)] if result.key?(nil)
          e.call(a, result)
        end
        [output, final.(result)]
      end
    end
  end
end
