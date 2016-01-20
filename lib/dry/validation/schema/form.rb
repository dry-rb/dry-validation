require 'dry/validation/schema'
require 'dry/validation/input_type_compiler'

module Dry
  module Validation
    class Schema::Form < Schema
      attr_reader :input_type

      def self.key(name, &block)
        if block
          super
        else
          super(name, &:filled?)
        end
      end

      def self.optional(name, &block)
        if block
          super
        else
          super(name, &:filled?)
        end
      end

      def initialize
        super
        @input_type = InputTypeCompiler.new.(self.class.rules.map(&:to_ary))
      end

      def call(input)
        super(input_type[input])
      end
    end
  end
end
