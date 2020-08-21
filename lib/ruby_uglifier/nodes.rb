require 'strings-case'

module RubyUglifier
  module Nodes
    module_function

    def parse(node)
      class_name = Strings::Case.pascalcase(node.type.to_s)
      return node unless Nodes.const_defined?(class_name, inherit = false)

      node_class = Nodes.const_get(class_name)
      node_class.new(node.type, node.children, location: node.location)
    end
  end
end
