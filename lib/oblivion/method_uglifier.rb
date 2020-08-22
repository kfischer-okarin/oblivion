# frozen_string_literal: true

module Oblivion
  class MethodUglifier < BaseProcessor
    def initialize(method_names)
      super()
      @method_names = method_names
    end

    def on_send(node)
      node.with_renamed_methods(@method_names)
    end
  end
end
