# frozen_string_literal: true

module Oblivion
  class ClassUglifier < Uglifier
    def self.process(node, renamer_class)
      renamer = InitializeRenamer.process(node, renamer_class)
      rewriter = new(renamer)
      node.updated(nil, rewriter.process_all(node))
    end

    def initialize(renamer)
      super(renamer.class)
      @renamer = renamer
    end

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
  end
end
