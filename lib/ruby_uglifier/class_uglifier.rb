require 'securerandom'

module RubyUglifier
  class ClassUglifier < BaseProcessor
    def initialize(methods)
      @method_names = {}
      methods.each do |name|
        @method_names[name] = random_method_name(name)
      end
    end

    LETTERS = ('a'..'z').to_a.freeze

    def on_def(node)
      name, args, body = node.children
      new_children = [*node.children]
      new_children[0] = @method_names[name] if @method_names.key? name
      new_children[2] = MethodUglifier.new(@method_names).process(body)

      node.updated(nil, new_children)
    end

    private

    def random_method_name(original_name)
      loop do
        new_name = LETTERS.sample + SecureRandom.alphanumeric(10)
        unless @method_names.key? new_name
          @method_names[original_name] = new_name
          return new_name
        end
      end
    end
  end
end
