module Dry
  module Rules
    module Embedded
      module_function

      def call(value, rules = {}, validator)
        if rules.respond_to?(:call)
          validator = rules
        else
          validator = validator.class.new(
            rules: rules,
            processor: validator.processor
          )
        end

        validator.call(value)
      end
    end
  end
end
