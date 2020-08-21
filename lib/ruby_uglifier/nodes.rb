require 'strings-case'

module RubyUglifier
  module Nodes
    class Def < Parser::AST::Node
      def name
        children[0]
      end

      def with_name(new_name)
        new_children = [*children]
        new_children[0] = new_name
        updated(nil, new_children)
      end

      def args
        children[1]
      end

      def body
        children[2]
      end

      def with_body(new_body)
        new_children = [*children]
        new_children[2] = new_body
        updated(nil, new_children)
      end
    end

    module_function

    def parse(node)
      class_name = Strings::Case.pascalcase(node.type.to_s)
      return node unless Nodes.const_defined?(class_name, inherit = false)

      node_class = Nodes.const_get(class_name)
      node_class.new(node.type, node.children, location: node.location)
    end
  end
end
