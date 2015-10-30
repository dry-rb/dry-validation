module Dry
  module Validation
    module Rules
      module Length
        module_function

        def call(value, options, _processor)
          options = { min: options.min, max: options.max } if options.is_a?(::Range)
          min = options.fetch(:min, -Float::INFINITY)
          max = options.fetch(:max, Float::INFINITY)
          {
            code: 'length',
            value: value,
            options: options
          } unless value.respond_to?(:length) && (min..max).include?(value.length)
        end
      end
    end
  end
end
