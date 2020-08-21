require 'strings-case'

module RubyUglifier
  module Nodes
    class Base < Parser::AST::Node
      class << self
        def children(*attribute_names)
          attribute_names.each.with_index do |name, i|
            define_getter(name, i)
            define_update_method(name, i)
          end
        end

        private

        def define_getter(name, child_index)
          define_method name do
            children[child_index]
          end
        end

        def define_update_method(name, child_index)
          define_method :"with_#{name}" do |new_value|
            new_children = [*children]
            new_children[child_index] = new_value
            updated(nil, new_children)
          end
        end
      end
    end

    class Def < Base
      children :name, :args, :body
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
