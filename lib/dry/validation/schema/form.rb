require 'dry/validation/schema'
require 'dry/validation/input_type_compiler'

module Dry
  module Validation
    class Schema::Form < Schema
      attr_reader :input_type

      def initialize(rules = [])
        super
        @input_type = InputTypeCompiler.new.(self.class.rules.map(&:to_ast))
      end

      def call(input)
        super(input_type[input])
      end
    end
  end
end
