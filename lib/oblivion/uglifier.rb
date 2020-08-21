module Oblivion
  class Uglifier < BaseProcessor
    def self.process(ast)
      new.process(ast)
    end

    alias :on_class :uglify_class

    private

    def initialize
      @method_names_by_class = {}
    end
  end
end
