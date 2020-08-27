# frozen_string_literal: true

module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast, renamer_class = nil)
      ClassUglifier.process(ast,  renamer_class)
    end

    def on_class(node)
      ClassUglifier.process(node, renamer_class)
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
