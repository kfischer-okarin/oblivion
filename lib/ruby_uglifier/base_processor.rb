require 'ast'

module RubyUglifier
  class BaseProcessor
    include AST::Processor::Mixin

    def handler_missing(node)
      new_children = node.children.map { |c|
        c.is_a?(AST::Node) ? process(c) : c
      }
      node.updated(nil, new_children)
    end
  end
end
