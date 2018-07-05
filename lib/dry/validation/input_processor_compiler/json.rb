module Dry
  module Validation
    class InputProcessorCompiler::JSON < InputProcessorCompiler
      PREDICATE_MAP = {
        default: 'string',
        none?: 'json.nil',
        bool?: 'bool',
        str?: 'string',
        int?: 'integer',
        float?: 'float',
        decimal?: 'json.decimal',
        date?: 'json.date',
        date_time?: 'json.date_time',
        time?: 'json.time'
      }.freeze

      CONST_MAP = {
        NilClass => 'nil',
        String => 'string',
        Integer => 'integer',
        Float => 'float',
        BigDecimal => 'json.decimal',
        Array => 'json.array',
        Hash => 'json.hash',
        Date => 'json.date',
        DateTime => 'json.date_time',
        Time => 'json.time',
        TrueClass => 'true',
        FalseClass => 'false'
      }.freeze

      def identifier
        :json
      end

      def hash_node(schema)
        [:json_hash, [schema, {}]]
      end

      def array_node(members)
        [:json_array, [members, {}]]
      end
    end
  end
end
