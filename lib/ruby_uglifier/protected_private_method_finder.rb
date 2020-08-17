module RubyUglifier
  class ProtectedPrivateMethodFinder < BaseProcessor
    attr_reader :result

    def initialize
      @access_modifier = :public
      @result = []
    end

    def on_def(node)
      @result << node.children[0] unless @access_modifier == :public

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
