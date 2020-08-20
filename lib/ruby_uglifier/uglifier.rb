module RubyUglifier
  class Uglifier < BaseProcessor
    def initialize
      @method_names_by_class = {}
    end

    def on_class(node)
      method_finder = MethodFinder.new
      method_finder.process_all(node.children)
      methods_to_uglify = (method_finder.result[:protected] | method_finder.result[:private]) - Set.new([:initialize])
      method_uglifier = ClassUglifier.new(methods_to_uglify)
      node.updated(nil, method_uglifier.process_all(node.children))
    end
  end
end
