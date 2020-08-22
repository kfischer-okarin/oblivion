# frozen_string_literal: true

module Oblivion
  class RewriteMethodBody < BaseProcessor
    def initialize(method_names)
      super()
      @method_names = method_names
    end

    def on_send(node)
      super(node).renamed(@method_names)
    end
  end
end
