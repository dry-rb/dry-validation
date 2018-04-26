require 'dry/monads/result'

module Dry
  module Validation
    class Result
      include Dry::Monads::Result::Mixin

      def to_monad(failure_value_as_message_set: false, **options)
        if success?
          Success(output)
        else
          if failure_value_as_message_set
            Failure(message_set(options))
          else
            Failure(messages(options))
          end
        end
      end
      alias_method :to_either, :to_monad
    end
  end
end
