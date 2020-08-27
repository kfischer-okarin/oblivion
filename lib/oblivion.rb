# frozen_string_literal: true

require 'unparser'

require_relative 'oblivion/renamer'
require_relative 'oblivion/nodes'
require_relative 'oblivion/base_processor'
require_relative 'oblivion/initialize_renamer'
require_relative 'oblivion/rewrite_method'
require_relative 'oblivion/rewrite_method_container'
require_relative 'oblivion/cli'

# :reek:IrresponsibleModule
module Oblivion
  module_function

  def uglify(source_code)
    ast = Unparser.parse(source_code)
    uglified_ast = RewriteMethodContainer.process(ast, Renamer::Random)
    Unparser.unparse(uglified_ast).gsub(/\n\s*/m, ';')
  end
end
