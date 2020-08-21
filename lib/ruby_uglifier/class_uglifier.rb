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
      result = node
      result = result.with_name @method_names[node.name] if @method_names.key?(node.name)
      result = result.with_body MethodUglifier.new(@method_names).process(node.body)

      result
    end

    # TODO: Uglify instance_variables
    # def on_send(node)
    #   method_name = node.children[1]
    #   return unless %i[attr_reader attr_writer attr_accessor].include? method_name

    #   new_children = [*node.children]
    #   define_method_indices = 2..(node.children.size - 1)

    #   define_method_indices.each do |i|
    #     name_node = new_children[i] # s(:sym, method_name)
    #     name = name_node.children[0]
    #     new_children[i] = name_node.updated(nil, [@method_names[name]]) if @method_names.key? name
    #   end
    #   node.updated(nil, new_children)
    # end

    alias :on_class :uglify_class
    alias :on_sclass :uglify_class

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
