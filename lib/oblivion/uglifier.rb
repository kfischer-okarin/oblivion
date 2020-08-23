# frozen_string_literal: true

module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast)
      new.process(ast)
    end

    def on_class(node)
      methods = MethodFinder.methods_of_class(node)
      methods_to_uglify = methods[:private] - Set.new([:initialize])
      node.with_processed_children ClassUglifier.new(methods_to_uglify)
    end

    alias on_sclass on_class

    private

    def initialize
      super
    end
  end
end
