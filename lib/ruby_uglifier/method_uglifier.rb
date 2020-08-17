module RubyUglifier
  class MethodUglifier < BaseProcessor
    def initialize(method_names)
      @method_names = method_names
    end

    def on_send(node)
      receiver, name = node.children
      return unless [nil, AST::Node.new(:self)].include? receiver

      new_children = [*node.children]
      new_children[1] = @method_names[name] || name
      node.updated(nil, new_children)
    end
  end
end
