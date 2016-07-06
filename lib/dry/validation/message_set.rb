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
        @hints = []
        @paths = map(&:path).uniq
        initialize_placeholders!
      end

      def empty?
        messages.empty?
      end

      def each(&block)
        return to_enum unless block
        messages.each(&block)
      end

      def with_hints!(hints)
        @hints = hints
        freeze
      end

      def to_h
        reduce(placeholders) do |hash, msg|
          if msg.root?
            (hash[nil] ||= []) << msg.to_s
          else
            node = msg.path.reduce(hash) { |a, e| a[e] }
            node << msg
            node.concat(hints.select { |hint| hint.add?(msg) })
            node.uniq!(&:signature)
            node.map!(&:to_s)
          end
          hash
        end
      end
      alias_method :to_hash, :to_h

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
