module Dry
  module Validation
    module TypeSpecs
      def build_array_type(spec, category)
        member_schema = build_type_map(spec, category)
        member_type = lookup_type("hash", category)
          .public_send(config.hash_type, member_schema)

        lookup_type("array", category).member(member_type)
      end

      def build_type_map(type_specs, category = config.input_processor)
        if type_specs.is_a?(Array)
          build_array_type(type_specs[0], category)
        else
          type_specs.each_with_object({}) do |(name, spec), result|
            result[name] =
              case spec
              when Hash
                lookup_type("hash", category).public_send(config.hash_type, spec)
              when Array
                if spec.size == 1
                  if spec[0].is_a?(Hash)
                    build_array_type(spec[0], category)
                  else
                    lookup_type("array", category).member(lookup_type(spec[0], category))
                  end
                else
                  spec
                    .map { |id| id.is_a?(Symbol) ? lookup_type(id, category) : id }
                    .reduce(:|)
                end
              when Symbol
                lookup_type(spec, category)
              else
                spec
              end
          end
        end
      end

      def lookup_type(name, category)
        id = "#{category}.#{name}"
        Types.type_keys.include?(id) ? Types[id] : Types[name.to_s]
      end
    end
  end
end
