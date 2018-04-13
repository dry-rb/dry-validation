require 'dry-struct'

module Dry
  module Validation
    class Schema
      module StructClassBuilder
        def create_class(target, other = nil)
          if other.is_a?(Class) && other < Dry::Struct
            super do
              other.schema.each do |attr, type|
                if type.primitive == Array
                  required(attr).each(type.member)
                else
                  required(attr).filled(type)
                end
              end
            end
          else
            super
          end
        end
      end

      module StructNode
        def node(input, *)
          if input.is_a?(::Class) && input < ::Dry::Struct
            [type, [name, [:schema, Schema.create_class(self, input)]]]
          else
            super
          end
        end
      end

      singleton_class.prepend(StructClassBuilder)
      Value.prepend(StructNode)
    end
  end
end
