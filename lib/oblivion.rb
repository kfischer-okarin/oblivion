require 'unparser'

require_relative 'oblivion/nodes'
require_relative 'oblivion/base_processor'
require_relative 'oblivion/method_finder'
require_relative 'oblivion/method_uglifier'
require_relative 'oblivion/class_uglifier'
require_relative 'oblivion/uglifier'

module Oblivion
  module_function

  def uglify(source_code)
    ast = Unparser.parse(source_code)
    uglified_ast = Uglifier.new.process(ast)
    Unparser.unparse(uglified_ast)
  end
end
