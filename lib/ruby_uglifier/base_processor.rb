require 'ast'

module RubyUglifier
  class BaseProcessor
    include AST::Processor::Mixin

    def on_begin(node)
      node.updated(nil, process_all(node.children))
    end
  end
end
