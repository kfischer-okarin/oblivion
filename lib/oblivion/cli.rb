# frozen_string_literal: true

require 'thor'
require_relative '../oblivion'

module Oblivion
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'ruby', 'Uglify a ruby file'
    def ruby(filename)
      File.open(filename) do |f|
        process_and_output_result(f.read)
      end
    end

    private

    def process_and_output_result(source)
      puts Oblivion.uglify(source)
    end
  end
end
