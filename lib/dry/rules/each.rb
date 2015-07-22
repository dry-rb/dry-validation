module Dry
  module Rules
    module Each
      module_function

      def call(value, rules = {}, validator)
        validator = validator.class.new(
          rules: rules,
          processor: validator.processor
        )

        value.map { |object| validator.call(object) }
      end
    end
  end
end
