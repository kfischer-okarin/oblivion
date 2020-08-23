# frozen_string_literal: true

require 'parser'

module Oblivion
  class BaseProcessor < Parser::AST::Processor
    def process(node)
      super Nodes.wrap(node)
    end

    def on_class(node)
      methods = MethodFinder.methods_of_class(node)
      methods_to_uglify = methods[:private] - Set.new([:initialize])
      node.with_processed_children ClassUglifier.new(methods_to_uglify)
    end

    alias on_sclass on_class

    def self.ignore_nodes(*types)
      do_nothing = ->(_node) {}
      types.each do |type|
        define_method :"on_#{type}", do_nothing
      end
    end
  end
end
