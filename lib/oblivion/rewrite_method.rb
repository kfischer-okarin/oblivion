# frozen_string_literal: true

module Oblivion
  # * Applies new method name if necessary
  # * Renames local variables
  # * Renames instance variables if a private accessor exists
  # * Renames argument names of private methods
  class RewriteMethod < BaseProcessor
    def initialize(renamer)
      super()
      @renamer = renamer
      @local_renamer = renamer.create_local_renamer
    end

    def on_def(node)
      result = node
      if @renamer.was_renamed? result.name
        result = result.renamed(@renamer)
                       .with_args(process(node.args))
      end
      result.with_body process(node.body)
    end

    def on_arg(node)
      @local_renamer.rename node.name
      node.renamed @local_renamer
    end

    def on_send(node)
      result = super(node)
      return result unless node.receiver_is_self? && @renamer.was_renamed?(node.method_name)

      result.renamed @renamer
    end

    def on_ivar(node)
      result = super(node)
      return result unless @renamer.was_renamed? node.name

      result.renamed @renamer
    end

    def on_ivasgn(node)
      result = super(node)
      return result unless @renamer.was_renamed? node.name

      result.renamed @renamer
    end

    def on_lvar(node)
      result = super(node)
      return result unless @local_renamer.was_renamed? node.name

      result.renamed @local_renamer
    end

    def on_lvasgn(node)
      @local_renamer.rename node.name unless @local_renamer.was_renamed? node.name
      super(node).renamed @local_renamer
    end
  end
end
