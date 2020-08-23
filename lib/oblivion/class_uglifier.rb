# frozen_string_literal: true

module Oblivion
  class ClassUglifier < Uglifier
    def initialize(renamer)
      super(renamer)
    end

    def on_def(node)
      result = node
      method_name = node.name
      result = result.with_name renamer.new_name_of(method_name) if renamer.was_renamed? method_name
      result.with_body RewriteMethodBody.new(renamer).process(node.body)
    end

    def on_send(node)
      return unless %i[attr_reader attr_writer attr_accessor].include? node.method_name

      super(node)
    end

    def on_sym(node)
      return node unless renamer.was_renamed? node.name

      node.renamed(renamer)
    end
  end
end
