module Dry
  module Validation
    module Rules
      module Presence
        module_function

        def call(value, switch, _processor)
          {
            code: 'presence',
            value: value,
            options: switch
          } if (switch == (value.respond_to?(:length) && value.length == 0))
        end
      end
    end
  end
end
