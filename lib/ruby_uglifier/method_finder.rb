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
      @result[@access_modifier] << method_name

      node
    end

    def on_send(node)
      called_method = node.children[1]
      return unless %i[public protected private].include? called_method

      @access_modifier = called_method
      node
    end
  end
end
