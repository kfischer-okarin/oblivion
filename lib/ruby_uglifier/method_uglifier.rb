module RubyUglifier
  class MethodUglifier < BaseProcessor
    def initialize(method_names)
      @method_names = method_names
    end

    def on_send(node)
      receiver, name = node.children

      new_children = [*node.children]
      if [nil, s(:self)].include? receiver
        new_children[1] = @method_names[name] || name
      elsif receiver.is_a?(AST::Node) && receiver.type == :send
        new_children[0] = process(receiver)
      end

      node.updated(nil, new_children)
    end

    def on_assign(node)
      right_side = node.children[1]
      new_children = [*node.children]
      new_children[1] = process(right_side)
      node.updated(nil, new_children)
    end

    alias :on_lvasgn :on_assign
    alias :on_ivasgn :on_assign
  end
end
