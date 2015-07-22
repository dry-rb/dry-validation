module Dry
  module Rules
    module Length
      module_function

      def call(value, options = {}, _validator = nil)
        if options.is_a?(::Range)
          options = {
            min: options.min,
            max: options.max
          }
        end

        min = options.fetch(:min, -Float::INFINITY)
        max = options.fetch(:max, Float::INFINITY)

        { code: 'length', options: options } unless (min..max).include?(value.length)
      end
    end
  end
end
