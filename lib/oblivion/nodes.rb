# frozen_string_literal: true

require 'strings-case'

module Oblivion
  module Nodes
    module_function

    def wrap(node)
      return node if node.is_a?(Nodes::Base) || !node.is_a?(AST::Node)

      wrapper_class_for(node).new(node.type, node.children, location: node.location)
    end

    def wrapper_class_for(node)
      class_name = Strings::Case.pascalcase(node.type.to_s)

      own_constant_defined?(class_name) ? Nodes.const_get(class_name) : Nodes::Base
    end

    def own_constant_defined?(name)
      const_defined?(name, false)
    end

    class Base < Parser::AST::Node
      class << self
        def children(*attribute_names)
          attribute_names.each.with_index do |name, index|
            child(name, index)
          end
        end

        def child(name, index)
          define_getter(name, index)
          define_update_method(name, index)
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

      def children
        super().map { |node| Nodes.wrap(node) }
      end

      def with_processed_children(processor)
        new_children = children.map { |child|
          child.is_a?(AST::Node) ? processor.process(child) : child
        }
        updated(nil, new_children)
      end
    end

    class Class < Base
    end

    class Sclass < Class; end

    class Def < Base
      children :name, :args, :body
    end

    class Send < Base
      children :receiver, :method_name

      child :args, (2..-1)

      def receiver_is_self?
        !receiver || receiver.type == :self
      end
    end

    class Sym < Base
      children :name
    end
  end
end
