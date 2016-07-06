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

        *arg_vals, _ = args.map(&:last)

        tokens = message_tokens(predicate, args)
        options = base_opts.update(lookup_options(base_opts, arg_vals))

        template = messages[predicate, options.update(tokens)]

        unless template
          raise MissingMessageError, "message for #{predicate} was not found"
        end

        name = options[:name]
        rule = options[:rule] || name

        text = message_text(rule, template, tokens, options)
        path = message_path(base_opts, name)

        message_class.new(
          predicate, path, text,
          args: arg_vals, rule: rule, each: base_opts[:each] == true
        )
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

      def lookup_options(_opts, arg_vals)
        { message_type: message_type,
          locale: locale,
          arg_type: arg_vals.size == 1 && arg_vals[0].class }
      end

      def message_text(rule, template, tokens, opts)
        text = template % tokens

        if full?
          rule_name = messages.rule(rule, opts) || rule
          "#{rule_name} #{text}"
        else
          text
        end
      end

      def message_path(opts, name)
        if name.is_a?(Array)
          name
        else
          path = opts[:path] || Array(name)

          if name && path.last != name
            path += [name]
          end

          path
        end
      end

      def message_tokens(predicate, args)
        meth = :"message_tokens_#{predicate}"

        defaults = Hash[args]

        if respond_to?(meth)
          defaults.merge!(__send__(meth, defaults))
        end

        defaults
      end

      def message_tokens_inclusion?(args)
        warn 'inclusion is deprecated - use included_in instead.'
        message_tokens_included_in?(args)
      end

      def message_tokens_exclusion?(args)
        warn 'exclusion is deprecated - use excluded_from instead.'
        message_tokens_excluded_from?(args)
      end

      def message_tokens_excluded_from?(args)
        { list: args[:list].join(', ') }
      end

      def message_tokens_included_in?(args)
        { list: args[:list].join(', ') }
      end

      def message_tokens_size?(args)
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
