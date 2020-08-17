require 'ast'
require 'securerandom'

module RubyUglifier
  class ClassUglifier
    include AST::Processor::Mixin

    def initialize
      @access_modifier = :public
    end

    LETTERS = ('a'..'z').to_a.freeze

    def on_def(node)
      return if @access_modifier == :public

      new_children = [*node.children]
      new_name = LETTERS.sample + SecureRandom.alphanumeric(10)
      new_children[0] = new_name

      node.updated(nil, new_children)
    end

    def on_begin(node)
      node.updated(nil, process_all(node.children))
    end

    def on_send(node)
      called_method = node.children[1]
      return unless %i[public protected private].include? called_method

      @access_modifier = called_method
      node
    end
  end
end
