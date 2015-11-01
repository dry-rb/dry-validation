module Dry
  module Validation
    module Rules
      module Each
        module_function

        def call(value, rules, processor)
          errors = value.map { |subject| processor.call(rules, subject) }
          {
            code: 'each',
            errors: errors,
            value: value,
            options: {}
          } unless errors.all?(&:empty?)
        end
      end
    end
  end
end
