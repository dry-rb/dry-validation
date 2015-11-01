module Dry
  module Validation
    # (Default) attribute extractor
    #
    # @example
    #
    #   Dry::Validation::AttributeExtractor.call({ name: 'Jack' }, :name)
    #     # => "Jack"
    #
    # @api public
    module AttributeExtractor
      module_function

      # Validate subject using validator
      #
      # @param [Mixed] subject The subject to extract the attribute from
      # @param [Mixed] attribute The attribute to extract
      #
      # @return [Mixed] value The attribute value
      #
      # @api public
      def call(subject, attribute)
        subject[attribute]
      end
    end
  end
end
