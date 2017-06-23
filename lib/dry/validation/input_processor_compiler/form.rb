module Dry
  module Validation
    class InputProcessorCompiler::Form < InputProcessorCompiler
      PREDICATE_MAP = {
        default: 'string',
        none?: 'form.nil',
        bool?: 'form.bool',
        true?: 'form.true',
        false?: 'form.false',
        str?: 'string',
        int?: 'form.int',
        float?: 'form.float',
        decimal?: 'form.decimal',
        date?: 'form.date',
        date_time?: 'form.date_time',
        time?: 'form.time',
        hash?: 'form.hash',
        array?: 'form.array'
      }.freeze

      CONST_MAP = {
        NilClass => 'form.nil',
        String => 'string',
        Integer => 'form.int',
        Float => 'form.float',
        BigDecimal => 'form.decimal',
        Array => 'form.array',
        Hash => 'form.hash',
        Date => 'form.date',
        DateTime => 'form.date_time',
        Time => 'form.time',
        TrueClass => 'form.true',
        FalseClass => 'form.false'
      }.freeze

      def identifier
        :form
      end

      def hash_node(schema)
        [:form_hash, [schema, {}]]
      end

      def array_node(members)
        [:form_array, [members, {}]]
      end
    end
  end
end
