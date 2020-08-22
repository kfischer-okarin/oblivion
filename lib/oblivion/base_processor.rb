# frozen_string_literal: true

require 'parser'

module Oblivion
  class BaseProcessor < Parser::AST::Processor
    def process(node)
      super Nodes.wrap(node)
    end

    def on_class(node)
      node.uglified
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
