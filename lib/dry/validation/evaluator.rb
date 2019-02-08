require 'dry/initializer'
require 'dry/validation/constants'

module Dry
  module Validation
    class Evaluator
      extend Dry::Initializer

      param :context

      option :name

      option :params

      attr_reader :message

      def initialize(*args, &block)
        super(*args)
        @failure = false
        instance_eval(&block)
      end

      def failure(message)
        @message = message
        @failure = true
        self
      end

      def failure?
        @failure.equal?(true)
      end

      private

      def method_missing(meth, *args, &block)
        # yes, we do want to delegate to private methods too
        if context.respond_to?(meth, true)
          context.__send__(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end
