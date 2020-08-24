# frozen_string_literal: true

module Oblivion
  class RewriteMethod < BaseProcessor
    def initialize(renamer)
      super()
      @renamer = renamer
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
      @renamer.rename :"lv_#{node.name}"
      node.renamed @renamer
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

    def on_lvar(node)
      result = super(node)
      return result unless @renamer.was_renamed?(:"lv_#{node.name}")

      result.renamed @renamer
    end

    def on_lvasgn(node)
      @renamer.rename :"lv_#{node.name}"
      super(node).renamed @renamer
    end
  end
end
