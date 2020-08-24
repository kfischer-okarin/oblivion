# frozen_string_literal: true

module Oblivion
  class ClassUglifier < Uglifier
    def initialize(renamer)
      super(renamer.class)
      @renamer = renamer
    end

    def on_def(node)
      result = node
      result = result.renamed(@renamer) if @renamer.was_renamed? result.name
      result.with_body RewriteMethodBody.new(@renamer).process(node.body)
    end

    def on_send(node)
      return unless %i[attr_reader attr_writer attr_accessor].include? node.method_name

      super(node)
    end

    def on_sym(node)
      return node unless @renamer.was_renamed? node.name

      node.renamed(@renamer)
    end
  end
end
