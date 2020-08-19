module RubyUglifier
  class ProtectedPrivateMethodFinder < BaseProcessor
    attr_reader :result

    def initialize
      @access_modifier = :public
      @result = []
    end

    def on_def(node)
      method_name = node.children[0]
      @result << method_name unless @access_modifier == :public || method_name == :initialize

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
