# frozen_string_literal: true

module Oblivion
  class RewriteMethodBody < BaseProcessor
    def initialize(method_names)
      super()
      @method_names = method_names
    end

    def on_send(node)
      result = super(node)
      return result unless node.receiver_is_self? && @method_names.key?(node.method_name)

      node.with_method_name(@method_names[node.method_name])
    end
  end
end
