# frozen_string_literal: true

require 'ast'
require 'parser'

module Oblivion
  # Parent class of all processors in this gem
  # Makes sure that nodes are wrapped into the right subclass
  class BaseProcessor < Parser::AST::Processor
    def process(node)
      return node unless node.is_a? AST::Node

      super Nodes.wrap(node)
    end
  end
end
