module RubyUglifier
  class Uglifier < BaseProcessor
    def initialize
      @method_names_by_class = {}
    end

    alias :on_class :uglify_class
  end
end
