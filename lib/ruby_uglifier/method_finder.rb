require 'set'

module RubyUglifier
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
      method_name = node.children[0]
      add method_name

      node
    end

    def on_class(node); end

    def on_sclass(node); end

    def on_send(node)
      called_method = node.children[1]
      case called_method
      when :public, :protected, :private
        @access_modifier = called_method
      # TODO: Uglify instance_variables
      # when :attr_reader, :attr_writer, :attr_accessor
      #   method_names = node.children[2..-1].map { |n| n.children[0] }
      #   method_names.each do |method_name|
      #     add_to_result method_name
      #   end
      end
      node
    end

    private

    def initialize
      @access_modifier = :public
    end

    def add(method_name)
      method_names[@access_modifier] << method_name
    end
  end
end
