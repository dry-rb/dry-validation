require 'dry-struct'

module Dry
  module Validation
    class Schema
      module StructClassBuilder
        def create_class(target, other = nil)
          _self = self
          if struct?(other)
            super do
              other.schema.each do |attr, type|
                chain = if type.meta[:omittable]
                  optional(attr)
                else
                  required(attr)
                end

                if _self.struct?(type)
                  chain.schema(type)
                elsif type.primitive == Array
                  if _self.struct?(type.member)
                    chain.each { schema(type.member) }
                  else
                    chain.each(type.member)
                  end
                else
                  chain.value(type)
                end
              end
            end
          else
            super
          end
        end

        def struct?(object)
          object.is_a?(Class) && object < Dry::Struct
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
