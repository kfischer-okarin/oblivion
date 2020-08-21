# frozen_string_literal: true

require 'ast'

module Oblivion
  class BaseProcessor
    include AST::Processor::Mixin

    def process(node)
      super(node ? Nodes.parse(node) : node)
    end

    def handler_missing(node)
      new_children = node.children.map { |child|
        child.is_a?(AST::Node) ? process(child) : child
      }
      node.updated(nil, new_children)
    end

    def uglify_class(node)
      methods = MethodFinder.methods_of_class(node)
      methods_to_uglify = methods[:private] - Set.new([:initialize])
      method_uglifier = ClassUglifier.new(methods_to_uglify)
      node.updated(nil, method_uglifier.process_all(node.children))
    end

    def self.ignore_nodes(*types)
      do_nothing = ->(_node) {}
      types.each do |type|
        define_method :"on_#{type}", do_nothing
      end
    end
  end
end
