require 'forwardable'

module Dry
  module Validation
    module ClassInterface
      extend Forwardable

      attr_reader :rules
      def_delegator :rules, :to_hash

      def inherited(klass)
        super
        klass.__send__(:instance_variable_set, :@rules, @rules)
      end
    end
  end
end
