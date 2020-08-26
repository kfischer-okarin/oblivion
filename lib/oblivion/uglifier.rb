# frozen_string_literal: true

module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast, renamer_class = nil)
      new(renamer_class).process(ast)
    end

    def on_class(node)
      renamer = renamer_class.new
      MethodFinder.methods_of_class(node, renamer)
      node.with_processed_children ClassUglifier.new(renamer)
    end

    alias on_sclass on_class
    alias on_casgn on_class

    protected

    attr_reader :renamer_class

    private

    def initialize(renamer_class)
      super()
      @renamer_class = renamer_class || Renamer::Random
    end
  end
end
