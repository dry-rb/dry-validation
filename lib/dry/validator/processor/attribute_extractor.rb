module Dry
  class Validator
    module Processor
      module AttributeExtractor
        module_function

        def call(object, attribute)
          object[attribute]
        end
      end
    end
  end
end
