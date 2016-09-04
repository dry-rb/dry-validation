require 'dry/validation/constants'

module Dry
  module Validation
    class MessageSet
      include Enumerable

      HINT_EXCLUSION = %i(key? filled? none? bool? str? int? float? decimal? date? date_time? time? hash? array?).freeze

      attr_reader :messages, :failures, :hints, :paths, :placeholders

      def self.[](messages)
        new(messages.flatten)
      end

      def initialize(messages)
        @messages = messages
        @hints = messages.select(&:hint?)
        @failures = messages - hints
        @paths = failures.map(&:path).uniq
        hints.reject! { |hint| HINT_EXCLUSION.include?(hint.predicate) }
        initialize_placeholders!
      end

      def dump
        root? ? to_a : to_h
      end

      def empty?
        messages.empty?
      end

      def root?
        !empty? && failures.all?(&:root?)
      end

      def each(&block)
        return to_enum unless block
        messages.each(&block)
      end

      def hint_map
        @hint_map ||= hints.group_by(&:path)
      end

      def to_h
        if root?
          { nil => failures.map(&:to_s) }
        else
          failures.group_by(&:path).reduce(placeholders) do |hash, (path, msgs)|
            node = path.reduce(hash) { |a, e| a[e] }

            msgs.each do |msg|
              node << msg

              msg_hints = hint_map[msg.index_path]
              node.concat(msg_hints) if msg_hints
            end

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
