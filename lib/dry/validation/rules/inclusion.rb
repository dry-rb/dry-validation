module Dry
  module Validation
    module Rules
      module Inclusion
        module_function

        def call(value, values, _processor)
          { code: 'inclusion', value: value, options: values } unless values.include?(value)
        end
      end
    end
  end
end
