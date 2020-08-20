require 'set'

module RubyUglifier
  class MethodFinder < BaseProcessor
    attr_reader :result

    def initialize
      @access_modifier = :public
      @result = { public: Set.new, protected: Set.new, private: Set.new }
    end

    def on_def(node)
      method_name = node.children[0]
      add_to_result method_name

      node
    end

    def on_class(node); end

    def on_sclass(node); end

    def on_send(node)
      called_method = node.children[1]
      case called_method
      when :public, :protected, :private
        @access_modifier = called_method
      when :attr_reader, :attr_writer, :attr_accessor
        method_names = node.children[2..-1].map { |n| n.children[0] }
        method_names.each do |method_name|
          add_to_result method_name
        end
      end
      node
    end

    private

    def add_to_result(method_name)
      @result[@access_modifier] << method_name
    end
  end
end
