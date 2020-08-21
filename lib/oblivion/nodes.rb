# frozen_string_literal: true

require 'strings-case'

module Oblivion
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
            new_children = Array.new(children)
            new_children[child_index] = new_value
            updated(nil, new_children)
          end
        end
      end

      def with_processed_children(processor)
        new_children = children.map { |child|
          child.is_a?(AST::Node) ? processor.process(child) : child
        }
        updated(nil, new_children)
      end
    end

    class Def < Base
      children :name, :args, :body
    end

    module_function

    def parse(node)
      node_type = node.type
      class_name = Strings::Case.pascalcase(node_type.to_s)

      node_class = own_constant_defined?(class_name) ? Nodes.const_get(class_name) : Base
      node_class.new(node_type, node.children, location: node.location)
    end

    def own_constant_defined?(name)
      const_defined?(name, false)
    end
  end
end
