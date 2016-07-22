require 'dry/validation/constants'

module Dry
  module Validation
    class MessageSet
      include Enumerable

      attr_reader :messages, :hints, :paths, :placeholders

      def self.[](messages)
        new(messages.flatten)
      end

      def initialize(messages)
        @messages = messages
        @hints = {}
        @paths = map(&:path).uniq
        initialize_placeholders!
      end

      def dump
        root? ? to_a : to_h
      end

      def empty?
        messages.empty?
      end

      def root?
        !empty? && messages.all?(&:root?)
      end

      def each(&block)
        return to_enum unless block
        messages.each(&block)
      end

      def with_hints!(hints)
        @hints = hints.group_by(&:index_path)
        self
      end

      def to_h
        if root?
          { nil => map(&:to_s) }
        else
          reduce(placeholders) do |hash, msg|
            node = msg.path.reduce(hash) { |a, e| a[e] }
            node << msg
            node.concat(Array(hints[msg.index_path]))
            node.uniq!(&:signature)
            node.map!(&:to_s)
            hash
          end
        end
      end
      alias_method :to_hash, :to_h

      def to_a
        to_h.values.flatten
      end

      private

      def initialize_placeholders!
        @placeholders = paths.reduce({}) do |hash, path|
          curr_idx = 0
          last_idx = path.size - 1
          node = hash

          while curr_idx <= last_idx do
            key = path[curr_idx]
            node = (node[key] || node[key] = curr_idx < last_idx ? {} : [])
            curr_idx += 1
          end

          hash
        end
      end
    end
  end
end
