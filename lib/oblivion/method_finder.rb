# frozen_string_literal: true

require 'set'

module Oblivion
  class MethodFinder < BaseProcessor
    def self.methods_of_class(class_node, renamer)
      class_node.with_processed_children new(renamer)
    end

    def on_def(node)
      add node.name
      node
    end

    ignore_nodes :class, :sclass

    def on_send(node)
      case node.method_name
      when :public, :protected, :private
        on_access_modifier(node)
      when :attr_reader, :attr_writer, :attr_accessor
        on_ivar_accessor(node)
      end
      node
    end

    private

    def initialize(renamer)
      super()
      @access_modifier = :public
      @renamer = renamer
    end

    def add(method_name)
      @renamer.rename method_name if @access_modifier == :private && method_name != :initialize
    end

    def on_access_modifier(node)
      @access_modifier = node.method_name
    end

    def on_ivar_accessor(node)
      method_names = node.args.map(&:name)
      method_names.each do |method_name|
        add method_name
      end
    end
  end
end
