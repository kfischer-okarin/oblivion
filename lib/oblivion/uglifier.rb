# frozen_string_literal: true

module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast, renamer = nil)
      new(renamer || Renamer::Random.new).process(ast)
    end

    def on_class(node)
      MethodFinder.methods_of_class(node, renamer)
      node.with_processed_children ClassUglifier.new(renamer)
    end

    alias on_sclass on_class

    protected

    attr_reader :renamer

    private

    def initialize(renamer)
      super()
      @renamer = renamer
    end
  end
end
