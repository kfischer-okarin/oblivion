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
      case node.method_name
      when :attr_reader, :attr_writer, :attr_accessor
        on_attribute_accessor node
      end
    end

    private

    def on_attribute_accessor(node)
      new_attribute_symbols = node.args.map { |attribute_symbol|
        next attribute_symbol unless @renamer.was_renamed? attribute_symbol.name

        attribute_symbol.renamed @renamer
      }
      node.with_args new_attribute_symbols
    end

    def initialize(renamer)
      super()
      @renamer = renamer
    end
  end
end
