# frozen_string_literal: true

module Oblivion
  # Renaming context for one class/struct/class method block
  class RewriteMethodContainer < BaseProcessor
    def self.process(node, renamer_class)
      renamer = InitializeRenamer.process(node, renamer_class)
      rewriter = new(renamer)
      node.updated(nil, rewriter.process_all(node))
    end

    def on_class(node)
      RewriteMethodContainer.process(node, @renamer.class)
    end

    alias on_sclass on_class
    alias on_casgn on_class

    def on_def(node)
      RewriteMethod.new(@renamer).process(node)
    end

    def on_send(node)
      return unless %i[attr_reader attr_writer attr_accessor].include? node.method_name

      node.with_args(node.args.map { |arg|
        next arg unless @renamer.was_renamed? arg.name

        arg.renamed @renamer
      })
    end

    private

    def initialize(renamer)
      super()
      @renamer = renamer
    end
  end
end
