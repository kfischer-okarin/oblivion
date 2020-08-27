# frozen_string_literal: true

module Oblivion
  # Scans the class for renameable methods and generates a renamer with new names for all of them
  class InitializeRenamer < BaseProcessor
    def self.process(class_node, renamer_class)
      new(renamer_class).tap { |processor|
        processor.process_all class_node
      }.renamer
    end

    attr_reader :renamer

    def on_def(node)
      add node.name
      node
    end

    def on_class(_node)
      # Do nothing
    end

    alias on_sclass on_class
    alias on_casgn on_class

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

    def initialize(renamer_class)
      super()
      @access_modifier = :public
      @renamer = renamer_class.new
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
