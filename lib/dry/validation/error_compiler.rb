module Dry
  module Validation
    class ErrorCompiler
      attr_reader :messages, :hints, :options, :locale

      DEFAULT_RESULT = {}.freeze
      EMPTY_HINTS = [].freeze
      KEY_SEPARATOR = '.'.freeze

      def initialize(messages, options = {})
        @messages = messages
        @options = Hash[options]
        @hints = @options.fetch(:hints, DEFAULT_RESULT)
        @full = @options.fetch(:full, false)
        @locale = @options.fetch(:locale, :en)
      end

      def message_type
        :failure
      end

      def full?
        @full
      end

      def call(ast)
        merge(ast.map { |node| visit(node) }) || DEFAULT_RESULT
      end

      def with(new_options)
        self.class.new(messages, options.merge(new_options))
      end

      def visit(node, *args)
        __send__(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_schema(node, opts = {})
        visit(node)
      end

      def visit_set(node)
        call(node)
      end

      def visit_error(node, opts = {})
        base_path, error = node
        node_path = Array(opts.fetch(:path, base_path))

        path = if base_path.is_a?(Array) && base_path.size > node_path.size
                 base_path
               else
                 node_path
               end

        text = messages[base_path]

        if text
          Message.new(base_path, node, path, text)
        else
          result = visit(error, opts.merge(path: path))

          case result
          when Hash then merge_hints(result)
          when Message then result.root? ? result : merge_hints(result)
          when Array then result
          end
        end
      end

      def visit_input(node, opts = {})
        rule, result = node
        visit(result, opts.merge(rule: rule))
      end

      def visit_result(node, opts = {})
        input, other = node
        visit(other, opts.merge(input: input))
      end

      def visit_implication(node, *args)
        _, right = node
        visit(right, *args)
      end

      def visit_key(node, opts = {})
        name, predicate = node
        visit(predicate, opts.merge(name: name))
      end

      def visit_val(node, opts = {})
        visit(node, opts)
      end

      def dump_messages(hash)
        hash.each_with_object({}) do |(key, val), res|
          res[key] =
            case val
            when Hash then dump_messages(val)
            when Array then val.map(&:to_s)
            end
        end
      end

      #### COPIED FROM ErrorCompiler::Input

      def visit_predicate(node, base_opts = {})
        predicate, args = node

        input, rule, name, val_type = base_opts
          .values_at(:input, :rule, :name, :val_type)

        is_hint = base_opts[:hint] == true
        is_each = base_opts[:each] == true

        val_type ||= input.class if input

        lookup_options = base_opts.merge(
          val_type: val_type,
          arg_type: args.size > 0 && args[0][1].class,
          message_type: message_type,
          locale: locale
        )

        tokens = options_for(predicate, args)
        template = messages[predicate, lookup_options.merge(tokens)]

        name ||= tokens[:name]
        rule ||= (name || tokens[:name])

        unless template
          raise MissingMessageError.new("message for #{predicate} was not found")
        end

        rule_name =
          if rule.is_a?(Symbol)
            messages.rule(rule, lookup_options) || rule
          else
            rule
          end

        text =
          if full?
            "#{rule_name || tokens[:name]} #{template % tokens}"
          else
            template % tokens
          end

        *arg_vals, _ = args.map(&:last)

        if name.is_a?(Array)
          path = name
        else
          path = base_opts.fetch(:path, Array(name))
          path = path + [name] unless path.last == name || name.nil?
        end

        msg = Message.new(rule, [predicate, arg_vals], path, text)
        msg.hint!(is_each) if is_hint
        msg
      end

      def visit_each(node, opts = {})
        merge(node.map { |el| visit(el, opts) }.map(&:to_h))
      end

      def visit_set(node, opts = {})
        result = node.map do |input|
          visit(input, opts)
        end
        merge(result)
      end

      def visit_el(node, opts = {})
        idx, el = node
        visit(el, opts.merge(path: opts[:path] + [idx]))
      end

      def visit_check(node, opts = {})
        path, other = node
        visit(other, opts.merge(path: Array(path)))
      end

      def options_for(predicate, args)
        meth = :"options_for_#{predicate}"

        defaults = Hash[args]

        if respond_to?(meth)
          defaults.merge!(__send__(meth, defaults))
        end

        defaults
      end

      def options_for_inclusion?(args)
        warn 'inclusion is deprecated - use included_in instead.'
        options_for_included_in?(args)
      end

      def options_for_exclusion?(args)
        warn 'exclusion is deprecated - use excluded_from instead.'
        options_for_excluded_from?(args)
      end

      def options_for_excluded_from?(args)
        { list: args[:list].join(', ') }
      end

      def options_for_included_in?(args)
        { list: args[:list].join(', ') }
      end

      def options_for_size?(args)
        size = args[:size]

        if size.is_a?(Range)
          { left: size.first, right: size.last }
        else
          args
        end
      end

      #### / COPIED FROM ErrorCompiler::Input

      private

      def merge_hints(messages, hints = self.hints)
        merge(Array[messages].flatten.map(&:to_h)).each_with_object({}) do |(name, msgs), res|
          res[name] =
            if msgs.is_a?(Hash)
              res[name] =
                if hints
                  merge_hints(msgs, hints[name])
                else
                  msgs
                end
            else
              candidates =
                if hints.is_a?(Array)
                  hints
                elsif hints.is_a?(Hash)
                  hints[name] || EMPTY_HINTS
                else
                  EMPTY_HINTS
                end

              all_hints =
                if name.is_a?(Symbol) && candidates.is_a?(Array)
                  candidates.reject(&:each?)
                else
                  candidates
                end

              if all_hints.is_a?(Array)
                all_msgs = msgs + all_hints
                all_msgs.uniq!(&:signature)
                all_msgs
              else
                msgs
              end
            end
        end
      end

      def merge(result)
        result
          .flatten
          .reject(&:empty?)
          .map(&:to_h)
          .reduce { |a, e| deep_merge(a, e) } || DEFAULT_RESULT
      end

      def deep_merge(left, right)
        left.merge(right) do |_, a, e|
          if a.is_a?(Hash)
            deep_merge(a, e)
          else
            a + e
          end
        end
      end
    end
  end
end

require 'dry/validation/error_compiler/input'
