module Dry
  module Rules
    module Embedded
      module_function

      def call(value, rules = {}, validator)
        validator.class.new(
          rules: rules,
          processor: validator.processor
        ).call(value)
      end
    end
  end
end
