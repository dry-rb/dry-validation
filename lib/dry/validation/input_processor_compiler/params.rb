module Dry
  module Validation
    class InputProcessorCompiler::Params < InputProcessorCompiler
      PREDICATE_MAP = {
        default: 'string',
        none?: 'params.nil',
        bool?: 'params.bool',
        true?: 'params.true',
        false?: 'params.false',
        str?: 'string',
        int?: 'params.integer',
        float?: 'params.float',
        decimal?: 'params.decimal',
        date?: 'params.date',
        date_time?: 'params.date_time',
        time?: 'params.time',
        hash?: 'params.hash',
        array?: 'params.array'
      }.freeze

      CONST_MAP = {
        NilClass => 'params.nil',
        String => 'string',
        Integer => 'params.integer',
        Float => 'params.float',
        BigDecimal => 'params.decimal',
        Array => 'params.array',
        Hash => 'params.hash',
        Date => 'params.date',
        DateTime => 'params.date_time',
        Time => 'params.time',
        TrueClass => 'params.true',
        FalseClass => 'params.false'
      }.freeze

      def identifier
        :params
      end

      def hash_node(schema)
        [:params_hash, [schema, {}]]
      end

      def array_node(members)
        [:params_array, [members, {}]]
      end
    end
  end
end
