require 'dry/validation/constants'
require 'dry/validation/message'
require 'dry/validation/message_set'

module Dry
  module Validation
    class MessageCompiler
      attr_reader :messages, :options, :locale, :default_lookup_options

      def initialize(messages, options = {})
        @messages = messages
        @options = options
        @full = @options.fetch(:full, false)
        @locale = @options.fetch(:locale, messages.default_locale)
        @default_lookup_options = { message_type: message_type, locale: locale }
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

        tokens = message_tokens(args)

        if base_opts[:message] == false
          return [predicate, arg_vals, tokens]
        end

        options = base_opts.update(lookup_options(base_opts, arg_vals))
        msg_opts = options.update(tokens)

        name = msg_opts[:name]
        rule = msg_opts[:rule] || name

        template = messages[predicate, msg_opts]

        unless template
          raise MissingMessageError, "message for #{predicate} was not found"
        end

        text = message_text(rule, template, tokens, options)
        path = message_path(msg_opts, name)

        message_class[
          predicate, path, text,
          args: arg_vals, rule: rule, each: base_opts[:each] == true
        ]
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

      def visit_xor(node, *args)
        _, right = node
        visit(right, *args)
      end

      def lookup_options(_opts, arg_vals = [])
        default_lookup_options.merge(
          arg_type: arg_vals.size == 1 && arg_vals[0].class
        )
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

      def message_tokens(args)
        args.each_with_object({}) { |arg, hash|
          case arg[1]
          when Array
            hash[arg[0]] = arg[1].join(', ')
          when Range
            hash["#{arg[0]}_left".to_sym] = arg[1].first
            hash["#{arg[0]}_right".to_sym] = arg[1].last
          else
            hash[arg[0]] = arg[1]
          end
        }
      end
    end
  end
end
