# frozen_string_literal: true

require 'securerandom'

module Oblivion
  class ClassUglifier < Uglifier
    def initialize(methods)
      super()
      @method_names = {}
      methods.each do |name|
        @method_names[name] = random_method_name(name)
      end
    end

    LETTERS = ('a'..'z').to_a.freeze

    def on_def(node)
      result = node
      method_name = node.name
      result = result.with_name @method_names[method_name] if @method_names.key? method_name
      result.with_body RewriteMethodBody.new(@method_names).process(node.body)
    end

    def on_send(node)
      return unless %i[attr_reader attr_writer attr_accessor].include? node.method_name

      super(node)
    end

    def on_sym(node)
      return node unless @method_names.key?(node.name)

      node.with_name(@method_names[node.name])
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
