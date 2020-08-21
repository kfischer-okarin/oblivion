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

    def uglify_class(node)
      methods = MethodFinder.methods_of_class(node)
      methods_to_uglify = methods[:private] - Set.new([:initialize])
      method_uglifier = ClassUglifier.new(methods_to_uglify)
      node.updated(nil, method_uglifier.process_all(node.children))
    end
  end
end
