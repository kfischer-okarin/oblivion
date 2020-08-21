module Oblivion
  class MethodUglifier < BaseProcessor
    def initialize(method_names)
      @method_names = method_names
    end

    def on_send(node)
      receiver, name, args = node.children

      new_children = [*node.children]
      if [nil, AST::Node.new(:self)].include? receiver
        new_children[1] = @method_names[name] || name
      else
        new_children[0] = process(receiver) if receiver.is_a? AST::Node
        new_children[2] = process(args) if args.is_a? AST::Node
      end

      node.updated(nil, new_children)
    end
  end
end
