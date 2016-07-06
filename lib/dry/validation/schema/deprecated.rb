require 'dry/validation/input_processor_compiler'

module Dry
  module Validation
    class Schema
      def self.input_processor
        @input_processor ||=
          begin
            if type_map.is_a?(Dry::Types::Safe) && config.input_processor != :noop
              type_map
            elsif type_map.size > 0 && config.input_processor != :noop
              build_hash_type(type_map)
            elsif input_processor_compiler
              input_processor_compiler.(rule_ast)
            else
              NOOP_INPUT_PROCESSOR
            end
          end
      end

      def self.input_processor_ast(type)
        config.input_processor_map.fetch(type).schema_ast(rule_ast)
      end

      def self.input_processor_compiler
        @input_processor_comp ||= config.input_processor_map[config.input_processor]
      end
    end
  end
end
