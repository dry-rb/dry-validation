module Dry
  module Rules
    module Each
      module_function

      def call(value, rules = {}, validator)
        if rules.is_a?(validator.class)
          validator = rules
        else
          validator = validator.class.new(
            rules: rules,
            processor: validator.processor
          )
        end

        value.map { |object| validator.call(object) }
      end
    end
  end
end
