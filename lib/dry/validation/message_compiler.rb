require 'dry/validation/constants'
require 'dry/validation/message'
require 'dry/validation/message_set'

module Dry
  module Validation
    class MessageCompiler
      attr_reader :messages, :options, :locale

      def initialize(messages, options = {})
        @messages = messages
        @options = options
        @full = @options.fetch(:full, false)
        @locale = @options.fetch(:locale, :en)
      end

      def call(ast)
        MessageSet[ast.map { |node| visit(node) }]
      end

      def full?
        @full
      end

      def with(new_options)
        return self if new_options.empty?
        self.class.new(messages, options.merge(new_options))
      end

      def visit(node, *args)
        __send__(:"visit_#{node[0]}", node[1], *args)
      end

      def visit_predicate(node, base_opts = EMPTY_HASH)
        predicate, args = node

        input, rule, name, val_type = base_opts
          .values_at(:input, :rule, :name, :val_type)

        val_type ||= input.class if input

        lookup_options = base_opts.update(
          val_type: val_type,
          arg_type: args.size > 0 && args[0][1].class,
          message_type: message_type,
          locale: locale
        )

        tokens = options_for(predicate, args)
        template = messages[predicate, lookup_options.update(tokens)]

        name ||= tokens[:name]
        rule ||= (name || tokens[:name])

        unless template
          raise MissingMessageError.new("message for #{predicate} was not found")
        end

        text =
          if full?
            rule_name = messages.rule(rule, lookup_options) || rule
            "#{rule_name} #{template % tokens}"
          else
            template % tokens
          end

        if name.is_a?(Array)
          path = name
        else
          path = base_opts.fetch(:path, Array(name))
          path = path + [name] unless path.last == name || name.nil?
        end

        is_each = base_opts[:each] == true

        *arg_vals, _ = args.map(&:last)
        message_class.new(predicate, path, text, args: arg_vals, rule: rule, each: is_each)
      end

      def visit_key(node, opts = EMPTY_HASH)
        name, predicate = node
        visit(predicate, opts.merge(name: name))
      end

      def visit_val(node, opts = EMPTY_HASH)
        visit(node, opts)
      end

      def visit_set(node, opts = EMPTY_HASH)
        node.map { |input| visit(input, opts) }
      end

      def visit_el(node, opts = EMPTY_HASH)
        idx, el = node
        visit(el, opts.merge(path: opts[:path] + [idx]))
      end

      def visit_implication(node, *args)
        _, right = node
        visit(right, *args)
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
    end
  end
end
