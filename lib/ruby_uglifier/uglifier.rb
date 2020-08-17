require 'ast'

module RubyUglifier
  class Uglifier
    include AST::Processor::Mixin

    def on_class(node)
      node.updated(nil, ClassUglifier.new.process_all(node.children))
    end
  end
end
