# frozen_string_literal: true

require 'set'

module Oblivion
  class MethodFinder < BaseProcessor
    def self.methods_of_class(class_node)
      new.instance_eval {
        process_all(class_node.children)
        method_names
      }
    end

    def method_names
      @method_names ||= {
        public: Set.new,
        protected: Set.new,
        private: Set.new
      }
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

    def initialize
      super
      @access_modifier = :public
    end

    def add(method_name)
      method_names[@access_modifier] << method_name
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
