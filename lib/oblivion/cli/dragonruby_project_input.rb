# frozen_string_literal: true

module Oblivion
  class CLI < Thor
    # Reads all files of a DragonRuby project and combines them into one
    class DragonrubyProjectInput
      attr_reader :data

      REQUIRE_STATEMENT = /^require\s+["'](?<filename>[^'"]+)['"].*\n/.freeze

      def initialize(path)
        @path = path
        @data = read_project_file 'app/main.rb'

        @data.gsub!(REQUIRE_STATEMENT) do |matched_string|
          match = REQUIRE_STATEMENT.match(matched_string)

          read_project_file match[:filename]
        end
      end

      private

      def read_project_file(relative_path)
        result = nil
        File.open("#{@path}/#{relative_path}") do |file|
          result = file.read
        end
        result
      end
    end
  end
end
