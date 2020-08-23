# frozen_string_literal: true

module Oblivion
  class ClassUglifier < Uglifier
    def initialize(renamer)
      super(renamer)
      @method_names = renamer.new_names
    end

    def on_def(node)
      result = node
      method_name = node.name
      result = result.with_name @method_names[method_name] if @method_names.key? method_name
      result.with_body RewriteMethodBody.new(@method_names).process(node.body)
    end

    def on_send(node)
      return unless %i[attr_reader attr_writer attr_accessor].include? node.method_name

      super(node)
    end

    def on_sym(node)
      return node unless @method_names.key?(node.name)

      node.with_name(@method_names[node.name])
    end
  end
end
