module Dry
  module Validation
    module TypeSpecs
      def self.extended(klass)
        super
        klass.class_eval do
          setting :input_processor, :noop
          setting :hash_type, :weak
          setting :type_map, {}
        end
      end

      def build_inherited_type_map(type_specs, inherited_specs)
        build_type_map(
          if Array === type_specs
            if inherited_specs.empty?
              type_specs
            elsif Dry::Types::Safe === inherited_specs
              raise InvalidSchemaError,
                "Composition of array schema type_maps not supported when config.type_specs = true"
            else
              raise InvalidSchemaError,
                "Extending non-array schema with an array type_map not supported when config.type_specs = true"
            end
          elsif Dry::Types::Safe === inherited_specs
            if type_specs.empty?
              inherited_specs
            elsif Array === type_specs
              raise InvalidSchemaError,
                "Composition of array schema type_maps not supported when config.type_specs = true"
            else
              raise InvalidSchemaError,
                "Extending array schema with a non-array type_map not supported when config.type_specs = true"
            end
          else
            inherited_specs.merge(type_specs)
          end
        )
      end

      def build_type_map(type_specs, category = config.input_processor)
        if type_specs.is_a?(Array)
          build_array_type(type_specs[0], category)
        else
          type_specs.reduce({}) { |res, (name, spec)|
            res.update(name => resolve_spec(spec, category))
          }
        end
      end

      def build_hash_type(spec = type_map)
        lookup_type("hash", config.input_processor)
          .public_send(config.hash_type, spec)
      end

      def build_array_type(spec, category)
        member_schema = build_type_map(spec, category)
        member_type = lookup_type("hash", category)
          .public_send(config.hash_type, member_schema)

        lookup_type("array", category).member(member_type)
      end

      def build_sum_type(spec, category)
        spec
          .map { |id| id.is_a?(Symbol) ? lookup_type(id, category) : id }
          .reduce(:|)
      end

      def resolve_spec(spec, category)
        case spec
        when Symbol
          lookup_type(spec, category)
        when Hash
          build_hash_type(spec)
        when Array
          if spec.size == 1
            if spec[0].is_a?(Hash)
              build_array_type(spec[0], category)
            else
              array_member = lookup_type(spec[0], category)
              lookup_type("array", category).member(array_member)
            end
          else
            build_sum_type(spec, category)
          end
        else
          spec
        end
      end

      def lookup_type(name, category)
        id = "#{category}.#{name}"
        Types.type_keys.include?(id) ? Types[id] : Types[name.to_s]
      end
    end
  end
end
