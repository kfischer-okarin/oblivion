# frozen_string_literal: true

module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast)
      new.process(ast)
    end

    private

    def initialize
      super
    end
  end
end
