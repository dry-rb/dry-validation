module Dry
  module Validation
    module Rules
      module Exclusion
        module_function

        def call(value, values, _processor)
          { code: 'exclusion', value: value, options: values } if values.include?(value)
        end
      end
    end
  end
end
