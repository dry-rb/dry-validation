module Dry
  module Validation
    class Evaluator
      attr_reader :name

      attr_reader :params

      attr_reader :msg

      def initialize(name, params, &block)
        @name = name
        @params = params
        @failure = false
        instance_eval(&block)
      end

      def failure(msg)
        @msg = msg
        @failure = true
        self
      end

      def failure?
        @failure.equal?(true)
      end

      def to_error
        { name => [msg] }
      end
    end
  end
end
