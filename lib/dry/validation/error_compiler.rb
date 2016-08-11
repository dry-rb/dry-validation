require 'dry/validation/message_compiler'

module Dry
  module Validation
    class ErrorCompiler < MessageCompiler
      def message_type
        :failure
      end

      def message_class
        Message
      end

      def visit_error(node, opts = EMPTY_HASH)
        rule, error = node
        node_path = Array(opts.fetch(:path, rule))

        path = if rule.is_a?(Array) && rule.size > node_path.size
                 rule
               else
                 node_path
               end

        path.compact!

        template = messages[rule.is_a?(Array) ? rule.last : rule, default_lookup_options]

        if template
          predicate, args, tokens = visit(error, opts.merge(path: path, message: false))
          message_class[predicate, path, template % tokens, rule: rule, args: args]
        else
          visit(error, opts.merge(rule: rule, path: path))
        end
      end

      def visit_input(node, opts = EMPTY_HASH)
        rule, result = node
        opt_rule = opts[:rule]

        if opts[:each] && opt_rule.is_a?(Array)
          visit(result, opts.merge(rule: rule, path: opts[:path] + [opt_rule.last]))
        else
          visit(result, opts.merge(rule: rule))
        end
      end

      def visit_result(node, opts = EMPTY_HASH)
        input, other = node
        visit(other, opts.merge(input: input))
      end

      def visit_each(node, opts = EMPTY_HASH)
        node.map { |el| visit(el, opts.merge(each: true)) }
      end

      def visit_schema(node, opts = EMPTY_HASH)
        path, other = node

        if opts[:path]
          visit(other, opts.merge(path: opts[:path] + [path.last]))
        else
          visit(other, opts.merge(path: [path], schema: true))
        end
      end

      def visit_check(node, opts = EMPTY_HASH)
        name, other = node

        if opts[:schema]
          visit(other, opts)
        else
          visit(other, opts.merge(path: Array(name)))
        end
      end

      def lookup_options(opts, arg_vals = [])
        super.update(val_type: opts[:input].class)
      end
    end
  end
end
