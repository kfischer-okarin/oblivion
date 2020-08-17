require 'unparser'

require_relative 'ruby_uglifier/class_uglifier'
require_relative 'ruby_uglifier/uglifier'

module RubyUglifier
  module_function

  def uglify(source_code)
    ast = Unparser.parse(source_code)
    uglified_ast = Uglifier.new.process(ast)
    Unparser.unparse(uglified_ast)
  end
end
