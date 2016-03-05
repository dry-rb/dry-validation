module Dry
  module Validation
    class Schema
      class Attr < Key
        def class
          Attr
        end

        def type
          :attr
        end
      end
    end
  end
end
