require 'dry/validation/schema'
require 'dry/validation/input_type_compiler'

module Dry
  module Validation
    class Schema::Form < Schema
      attr_reader :input_type

      def initialize
        super
        @input_type = InputTypeCompiler.new.(self.class.rules.map(&:to_ary))
      end

      def call(input)
        super(Validation.symbolize_keys(input_type[input]))
      end
    end
  end
end
