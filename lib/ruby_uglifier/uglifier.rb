module RubyUglifier
  class Uglifier < BaseProcessor
    def on_class(node)
      method_finder = ProtectedPrivateMethodFinder.new
      method_finder.process_all(node.children)
      method_uglifier = ClassUglifier.new(method_finder.result)
      node.updated(nil, method_uglifier.process_all(node.children))
    end
  end
end
