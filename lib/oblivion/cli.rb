# frozen_string_literal: true

require 'thor'
require_relative 'cli/single_file_input'
require_relative '../oblivion'

module Oblivion
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'ruby', 'Uglify a ruby file'
    def ruby(filename)
      process_and_output_result SingleFileInput.new(filename).data
    end

    private

    def process_and_output_result(source)
      puts Oblivion.uglify(source)
    end
  end
end
