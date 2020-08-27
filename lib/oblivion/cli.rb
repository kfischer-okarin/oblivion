# frozen_string_literal: true

require 'thor'
require_relative 'cli/single_file_input'
require_relative 'cli/dragonruby_project_input'
require_relative '../oblivion'

module Oblivion
  # Defines all CLI commands
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'ruby <filename>', 'Uglify a ruby file'
    def ruby(filename)
      process_and_output_result SingleFileInput.new(filename).data
    end

    desc 'dragonruby <path>', 'Uglify a DragonRuby project'
    def dragonruby(path)
      process_and_output_result DragonrubyProjectInput.new(path).data
    end

    private

    def process_and_output_result(source)
      puts Oblivion.uglify(source)
    end
  end
end
