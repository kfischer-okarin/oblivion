# frozen_string_literal: true

module Oblivion
  class RewriteMethod < BaseProcessor
    def initialize(renamer)
      super()
      @renamer = renamer
    end

    def on_def(node)
      result = node
      result = result.renamed(@renamer) if @renamer.was_renamed? result.name
      super(result)
    end

    def on_send(node)
      result = super(node)
      return result unless node.receiver_is_self? && @renamer.was_renamed?(node.method_name)

      result.renamed @renamer
    end

    def on_ivar(node)
      result = super(node)
      return result unless @renamer.was_renamed?(node.name)

      result.renamed @renamer
    end

    def on_ivasgn(node)
      result = super(node)
      return result unless @renamer.was_renamed?(node.name)

      result.renamed @renamer
    end
  end
end
