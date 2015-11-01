module Dry
  module Validation
    module Rules
      module Embedded
        module_function

        def call(value, rules, processor)
          errors = processor.call(rules, value)
          {
            code: 'embedded',
            errors: errors,
            value: value,
            options: {}
          } if errors.any?
        end
      end
    end
  end
end
