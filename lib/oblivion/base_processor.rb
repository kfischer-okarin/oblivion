# frozen_string_literal: true

require 'ast'
require 'parser'

module Oblivion
  class BaseProcessor < Parser::AST::Processor
    def process(node)
      return node unless node.is_a? AST::Node

      super Nodes.wrap(node)
    end

    def self.ignore_nodes(*types)
      do_nothing = ->(_node) {}
      types.each do |type|
        define_method :"on_#{type}", do_nothing
      end
    end
  end
end
