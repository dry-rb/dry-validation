require 'dry/validation/schema'
require 'dry/validation/input_type_compiler'

module Dry
  module Validation
    class Schema::Form < Schema
      option :input_type

      def self.default_options
        super.merge(input_type: input_type)
      end

      def call(input)
        super(input_type[input])
      end
    end
  end
end
